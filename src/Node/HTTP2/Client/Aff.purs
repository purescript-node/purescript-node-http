-- | Bindings to the *Node.js* HTTP/2 Client Core API.
-- |
-- | ## Client-side example
-- |
-- | Equivalent to
-- | [*Node.js* HTTP/2 Core API __Client-side example__](https://nodejs.org/docs/latest/api/http2.html#client-side-example)
-- |
-- | ```
-- | import Node.Stream.Aff (readAll)
-- |
-- | ca <- liftEffect $ Node.FS.Sync.readFile "localhost-cert.pem"
-- |
-- | either (liftEffect <<< Console.errorShow) pure =<< attempt do
-- |   client <- connect
-- |     (toOptions {ca})
-- |     (URL.parse "https://localhost:8443")
-- |
-- |   stream <- request client
-- |     (toOptions {})
-- |     (toHeaders {":path": "/"})
-- |
-- |   headers <- waitResponse stream
-- |   liftEffect $ for_ (headerKeys headers) \name ->
-- |     Console.log $
-- |       name <> ": " <> fromMaybe "" (headerString headers name)
-- |
-- |   body <- toStringUTF8 =<< (fst <$> readAll (toDuplex stream))
-- |   liftEffect $ Console.log $ "\n" <> body
-- |
-- |   closeSession client
-- | ```
module Node.HTTP2.Client.Aff
  ( connect
  , request
  , waitResponse
  , waitPush
  , waitHeadersAdditional
  , waitEnd
  , waitWantTrailers
  , sendTrailers
  , closeStream
  , closeSession
  , module ReClient
  ) where

import Prelude

import Control.Alt (alt)
import Control.Parallel (parallel, sequential)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff, effectCanceler, makeAff, nonCanceler)
import Effect.Exception (catchException)
import Node.HTTP2 (HeadersObject, OptionsObject)
import Node.HTTP2.Client (ClientHttp2Session, ClientHttp2Stream, toDuplex)
import Node.HTTP2.Client (ClientHttp2Session, ClientHttp2Stream, toDuplex) as ReClient
import Node.HTTP2.Client as Client
import Node.Stream.Aff.Internal as Node.Stream.Aff.Internal
import Node.URL (URL)

-- | Connect a client `Http2Session`.
-- |
-- | See [`http2.connect(authority[, options][, listener])`](https://nodejs.org/docs/latest/api/http2.html#http2connectauthority-options-listener)
connect :: OptionsObject -> URL -> Aff ClientHttp2Session
connect options url = makeAff \complete -> do
  _ <- Client.connectWithError url options
    (\session _ -> complete (Right session))
    (\err -> complete (Left err))
  pure nonCanceler

-- | Gracefully closes the `Http2Session`, allowing any existing streams
-- | to complete on their own and preventing new `Http2Stream` instances
-- | from being created.
-- |
-- | See [`http2session.close([callback])`](https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback)
closeSession :: ClientHttp2Session -> Aff Unit
closeSession session = makeAff \complete -> do
  catchException (complete <<< Left) do
    Client.closeSession session do
      (complete (Right unit))
  pure nonCanceler

-- | Begin a client request to the connected server.
-- |
-- | See [`clienthttp2session.request(headers[, options])`](https://nodejs.org/docs/latest/api/http2.html#clienthttp2sessionrequestheaders-options)
-- |
-- | With `toOptions {endStream: false}`, this can be followed by calls
-- | to
-- | [`Node.Stream.Aff.write`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:write)
-- | and
-- | [`Node.Stream.Aff.end`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:end).
-- | The default is `{endStream: true}`.
-- |
-- | Follow with calls to
-- | `waitResponse`
-- | and
-- | [`Node.Stream.Aff.readAll`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:readAll).
request :: ClientHttp2Session -> OptionsObject -> HeadersObject -> Aff ClientHttp2Stream
request session options headers = makeAff \complete -> do
  -- One of the request() options is `abortsignal` which takes a
  -- Web.Fetch.AbortController.signal.
  -- We want the request() to be cancellable.
  -- Unfortunately request() is completely synchronous so there is no way
  -- to asynchronously wait on it or cancel the request().
  stream <- catchException (pure <<< Left) do
    Right <$> Client.request session headers options
  complete stream
  pure nonCanceler

-- | Wait to receive response headers from the server.
-- |
-- | Follow with
-- | `waitPush` or
-- | [`Node.Stream.Aff.readAll`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:readAll).
waitResponse :: ClientHttp2Stream -> Aff HeadersObject
waitResponse stream = makeAff \complete -> do
  onceErrorStreamCancel <- Client.onceErrorStream stream (complete <<< Left)
  onceResponseCancel <- Client.onceResponse stream \headers _ -> do
    onceErrorStreamCancel
    complete (Right headers)
  pure $ effectCanceler do
    onceErrorStreamCancel
    onceResponseCancel

-- | Wait to receive a pushed stream from the server.
-- |
-- | Returns the client request headers for a request which the client
-- | did not send, and also the response headers and the pushed stream.
-- |
-- | See [Push streams on the client](https://nodejs.org/docs/latest/api/http2.html#push-streams-on-the-client)
-- |
-- | Follow with
-- | [`Node.Stream.Aff.readAll`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:readAll).
waitPush
  :: ClientHttp2Session
  -> Aff { headersRequest :: HeadersObject, headersResponse :: HeadersObject, streamPushed :: ClientHttp2Stream }
waitPush session = do
  { streamPushed, headersRequest } <- waitStream
  { headersResponse } <- waitPush' streamPushed
  pure { headersRequest, headersResponse, streamPushed }
  where
  waitStream = makeAff \complete -> do
    -- What if there is some other session error event while we're waiting
    -- for 'stream' and concurrently (parSequence_) waiting for some other event?
    -- Maybe it's right that all waiters get errored.
    -- Do we need to remove the once 'stream' event too in error event handler?
    onceErrorSessionCancel <- Client.onceErrorSession session (complete <<< Left)
    onceStreamCancel <- Client.onceStream session \streamPushed headersRequest _ -> do
      onceErrorSessionCancel
      complete (Right { streamPushed, headersRequest })
    pure $ effectCanceler do
      onceErrorSessionCancel
      onceStreamCancel
  waitPush' streamPushed = makeAff \complete -> do
    onceErrorStreamCancel <- Client.onceErrorStream streamPushed (complete <<< Left)
    oncePushCancel <- Client.oncePush streamPushed \headersResponse _ -> do
      onceErrorStreamCancel
      complete (Right { headersResponse })
    pure $ effectCanceler do
      onceErrorStreamCancel
      oncePushCancel

-- | Wait for an additional block of headers to be received from a stream,
-- | such as when a block of `1xx` informational headers is received.
-- |
-- | See
-- | [Event: `'headers'`](https://nodejs.org/docs/latest/api/http2.html#event-headers)
waitHeadersAdditional :: ClientHttp2Stream -> Aff HeadersObject
waitHeadersAdditional stream = makeAff \complete -> do
  onceErrorStreamCancel <- Client.onceErrorStream stream (complete <<< Left)
  onceHeadersCancel <- Client.onceHeaders stream \headers _ -> do
    onceErrorStreamCancel
    complete (Right headers)
  pure $ effectCanceler do
    onceErrorStreamCancel
    onceHeadersCancel

-- | Close the client stream.
-- |
-- | See [`http2stream.close(code[, callback])`](https://nodejs.org/docs/latest/api/http2.html#http2streamclosecode-callback)
-- |
-- | Note that `http2stream.close()` __cannot__ be called instead of
-- | `http2stream.sendTrailers()` as suggested by this passage.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#clienthttp2sessionrequestheaders-options
-- |
-- | > When `options.waitForTrailers` is set, the `Http2Stream` will
-- | > not automatically close when the final `DATA` frame is
-- | > transmitted. User code must call either
-- | > `http2stream.sendTrailers()` or `http2stream.close()` to
-- | > close the `Http2Stream`.
-- |
closeStream :: ClientHttp2Stream -> Int -> Aff Unit
closeStream stream code = makeAff \complete -> do
  catchException (complete <<< Left) do
    Client.closeStream stream code $ complete (Right unit)
  pure nonCanceler

-- | Wait for the
-- | [`wantTrailers`](https://nodejs.org/docs/latest/api/http2.html#event-wanttrailers)
-- | event.
-- |
-- | > When initiating a `request` or `response`, the `waitForTrailers` option must
-- | > be set for this event to be emitted.
-- |
-- | Follow this with a call to `sendTrailers`.
waitWantTrailers :: ClientHttp2Stream -> Aff Unit
waitWantTrailers stream = makeAff \complete -> do
  onceWantTrailersCancel <- Client.onceWantTrailers stream $ complete (Right unit)
  pure $ effectCanceler do
    onceWantTrailersCancel

-- | Send a trailing `HEADERS` frame to the connected HTTP/2 peer.
-- | This will cause the `Http2Stream` to immediately close and must
-- | only be called after the final `DATA` frame is signalled with
-- | [`Node.Stream.Aff.end`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:end).
-- |
-- | See [`http2stream.sendTrailers(headers)`](https://nodejs.org/docs/latest/api/http2.html#http2streamsendtrailersheaders)
-- |
-- | > When sending a request or sending a response, the
-- | > `options.waitForTrailers` option must be set in order to keep
-- | > the `Http2Stream` open after the final `DATA` frame so that
-- | > trailers can be sent.
sendTrailers :: ClientHttp2Stream -> HeadersObject -> Aff Unit
sendTrailers stream headers = makeAff \complete -> do
  catchException (complete <<< Left) do
    Client.sendTrailers stream headers
    complete (Right unit)
  pure nonCanceler

-- | Wait for the end of the `Readable` response stream from the server.
-- | Maybe return
-- | trailing header fields (“trailers”) if found at the end of the stream.
waitEnd :: ClientHttp2Stream -> Aff (Maybe HeadersObject)
waitEnd stream = do
  result :: Either HeadersObject Unit <- sequential $
    alt
      do
        parallel do
          Left <$> waitTrailers stream
      do
        parallel do
          Right <$> waitEnd' stream
  case result of
    Left trailers -> do
      waitEnd' stream
      pure (Just trailers)
    Right _ -> pure Nothing
  where

  -- | Wait to receive a block of headers associated with trailing header fields.
  -- |
  -- | See
  -- | [Event: `'trailers'`](https://nodejs.org/docs/latest/api/http2.html#event-trailers)
  waitTrailers :: ClientHttp2Stream -> Aff HeadersObject
  waitTrailers stream' = makeAff \complete -> do
    onceErrorStreamCancel <- Client.onceErrorStream stream' (complete <<< Left)
    onceTrailersCancel <- Client.onceTrailers stream' \headers _flags -> do
      onceErrorStreamCancel
      complete (Right headers)
    pure $ effectCanceler do
      onceErrorStreamCancel
      onceTrailersCancel

  -- | Wait for the end of the `Readable` stream from the server.
  waitEnd' :: ClientHttp2Stream -> Aff Unit
  waitEnd' stream' = makeAff \complete -> do
    readable <- Node.Stream.Aff.Internal.readable (toDuplex stream')
    if readable then do
      onceErrorStreamCancel <- Client.onceErrorStream stream' (complete <<< Left)
      onceEndCancel <- Client.onceEnd stream' $ complete (Right unit)
      pure $ effectCanceler do
        onceErrorStreamCancel
        onceEndCancel
    else do
      complete (Right unit)
      pure nonCanceler
