-- | Bindings to the *Node.js* HTTP/2 Server Core API.
-- |
-- | ## Server-side example
-- |
-- | Equivalent to
-- | [*Node.js* HTTP/2 Core API __Server-side example__](https://nodejs.org/docs/latest/api/http2.html#server-side-example)
-- |
-- | ```
-- | import Node.Stream.Aff (write, end)
-- |
-- | key <- Node.FS.Sync.readFile "localhost-privkey.pem"
-- | cert <- Node.FS.Sync.readFile "localhost-cert.pem"
-- |
-- | either (liftEffect <<< Console.errorShow) pure =<< attempt do
-- |   server <- createSecureServer (toOptions {key, cert})
-- |   listenSecure server (toOptions {port:8443})
-- |     \session headers stream -> do
-- |       respond stream
-- |         (toOptions {})
-- |         (toHeaders
-- |           { "content-type": "text/html; charset=utf-8"
-- |           , ":status": 200
-- |           }
-- |         )
-- |       write (toDuplex stream) =<< fromStringUTF8 ("<h1>Hello World<hl>")
-- |       end (toDuplex stream)
-- | ```
module Node.HTTP2.Server.Aff
  ( createServer
  , listen
  , createSecureServer
  , listenSecure
  , respond
  , pushAllowed
  , pushStream
  , sendHeadersAdditional
  , waitEnd
  , waitWantTrailers
  , sendTrailers
  , closeStream
  , closeSession
  , closeServer
  , closeSecureServer
  , module ReServer
  ) where

import Prelude

import Control.Alt (alt)
import Control.Parallel (parallel, sequential)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Nullable (toMaybe)
import Effect.Aff (Aff, effectCanceler, launchAff_, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Exception (catchException)
import Node.HTTP2 (HeadersObject, OptionsObject)
import Node.HTTP2.Server (Http2SecureServer, Http2Server, ServerHttp2Session, ServerHttp2Stream, toDuplex)
import Node.HTTP2.Server (Http2Server, Http2SecureServer, ServerHttp2Session, ServerHttp2Stream, toDuplex) as ReServer
import Node.HTTP2.Server as Server
import Node.Stream.Aff.Internal as Node.Stream.Aff.Internal

-- | Create an insecure (HTTP) HTTP/2 server.
-- |
-- | The argument is the `createServer` options.
-- | See [`http2.createServer([options][, onRequestHandler])`](https://nodejs.org/docs/latest/api/http2.html#http2createserveroptions-onrequesthandler)
createServer
  :: OptionsObject
  -> Aff Http2Server
createServer options = makeAff \complete -> do
  catchException (complete <<< Left) do
    server <- Server.createServer options
    complete (Right server)
  pure nonCanceler

-- | Open one listening socket for unencrypted connections.
-- |
-- | For each new client connection and request, the handler function will
-- | be invoked by `launchAff` and passed the request.
-- | This makes the handler function uncancellable.
-- |
-- | Will complete after the socket has stopped listening and closed.
-- |
-- | Errors will be thrown through the `Aff` `MonadThrow` instance.
-- |
-- | Listening may be stopped explicity by calling `closeServer` on the
-- | server, or implicitly by `killFiber`.
-- |
-- | For the `listen` options,
-- | see [`server.listen(options[, callback])`](https://nodejs.org/docs/latest/api/net.html#serverlistenoptions-callback)
listen
  :: Http2Server
  -> OptionsObject
  -> (ServerHttp2Session -> HeadersObject -> ServerHttp2Stream -> Aff Unit)
  -> Aff Unit
listen server options handler = makeAff \complete -> do
  -- The Http2Server is a tls.Server
  -- https://nodejs.org/docs/latest/api/tls.html#event-tlsclienterror
  -- The Http2Server is a net.Server
  -- https://nodejs.org/docs/latest/api/net.html#event-error
  -- The Http2Server is an EventEmitter.
  -- https://nodejs.org/docs/latest/api/events.html#class-eventemitter

  onStreamCancel <- Server.onStream server \stream headers _ -> do
    launchAff_ $ handler (Server.session stream) headers stream

  -- https://nodejs.org/docs/latest/api/net.html#event-error
  -- “the 'close' event will not be emitted directly following this event unless server.close() is manually called.”
  onErrorCancel <- Server.onErrorServer server \err -> do
    onStreamCancel
    -- The socket must be closed when listening completes.
    Server.closeServer server $ pure unit
    complete (Left err)

  onceCloseCancel <- Server.onceCloseServer server do
    onStreamCancel
    onErrorCancel
    complete (Right unit)

  Server.listen server options do
    -- We don't want to complete here.
    pure unit

  pure $ effectCanceler do
    onStreamCancel
    onErrorCancel
    onceCloseCancel
    Server.closeServer server $ pure unit

-- | Create a secure (HTTPS) HTTP/2 server.
-- |
-- | The argument is the `createServer` options.
-- | See [`http2.createServer([options][, onRequestHandler])`](https://nodejs.org/docs/latest/api/http2.html#http2createserveroptions-onrequesthandler)
-- |
-- | Required options: `key :: String`, `cert :: String`.
createSecureServer
  :: OptionsObject
  -> Aff Http2SecureServer
createSecureServer options = makeAff \complete -> do
  catchException (complete <<< Left) do
    server <- Server.createSecureServer options
    complete (Right server)
  pure nonCanceler

-- | Secure version of `listen`. Open one listening socket
-- | for encrypted connections.
-- |
-- | For each new client connection and request, the handler function will
-- | be invoked by `launchAff` and passed the request.
-- | This makes the handler function uncancellable.
-- |
-- | Will complete after the socket has stopped listening and closed.
-- |
-- | Errors will be thrown through the `Aff` `MonadThrow` instance.
-- |
-- | Listening may be stopped explicity by calling `closeSecureServer` on the
-- | server, or implicitly by `killFiber`.
-- |
-- | For the `listen` options,
-- | see [`server.listen(options[, callback])`](https://nodejs.org/docs/latest/api/net.html#serverlistenoptions-callback)
listenSecure
  :: Http2SecureServer
  -> OptionsObject
  -> (ServerHttp2Session -> HeadersObject -> ServerHttp2Stream -> Aff Unit)
  -> Aff Unit
listenSecure server options handler = makeAff \complete -> do
  -- The Http2Server is a tls.Server
  -- https://nodejs.org/docs/latest/api/tls.html#event-tlsclienterror
  -- The Http2Server is a net.Server
  -- https://nodejs.org/docs/latest/api/net.html#event-error
  -- The Http2Server is an EventEmitter.
  -- https://nodejs.org/docs/latest/api/events.html#class-eventemitter

  onStreamCancel <- Server.onStreamSecure server \stream headers _ -> do
    launchAff_ $ handler (Server.session stream) headers stream

  -- https://nodejs.org/docs/latest/api/net.html#event-error
  -- “the 'close' event will not be emitted directly following this event unless server.close() is manually called.”
  onErrorCancel <- Server.onErrorServerSecure server \err -> do
    onStreamCancel
    -- The socket must be closed when listening completes.
    Server.closeServerSecure server $ pure unit
    complete (Left err)

  onceCloseCancel <- Server.onceCloseServerSecure server do
    onStreamCancel
    onErrorCancel
    complete (Right unit)

  Server.listenSecure server options do
    -- We don't want to complete here.
    pure unit

  pure $ effectCanceler do
    onStreamCancel
    onErrorCancel
    onceCloseCancel
    Server.closeServerSecure server $ pure unit

-- | Begin a server response.
-- |
-- | Follow this with calls to
-- | [`Node.Stream.Aff.write`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:write)
-- | and
-- | [`Node.Stream.Aff.end`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:end).
-- |
-- | See
-- | [`http2stream.respond([headers[, options]])`](https://nodejs.org/docs/latest/api/http2.html#http2streamrespondheaders-options)
respond :: ServerHttp2Stream -> OptionsObject -> HeadersObject -> Aff Unit
respond stream options headers = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.respond stream headers options
    -- TODO wait for respond send?
    complete (Right unit)
  pure nonCanceler

-- | Gracefully closes the `Http2Session`, allowing any existing streams
-- | to complete on their own and preventing new `Http2Stream` instances
-- | from being created.
-- |
-- | See [`http2session.close([callback])`](https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback)
closeSession :: ServerHttp2Session -> Aff Unit
closeSession session = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.closeSession session do
      (complete (Right unit))
  pure nonCanceler

-- | Close the server listening socket. Will complete after socket is closed.
-- |
-- | See [`http2server.close([callback])`](https://nodejs.org/docs/latest/api/http2.html#serverclosecallback)
closeServer :: Http2Server -> Aff Unit
closeServer server = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.closeServer server $ complete (Right unit)
  pure nonCanceler

-- | Close the server listening socket. Will complete after socket is closed.
closeSecureServer :: Http2SecureServer -> Aff Unit
closeSecureServer server = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.closeServerSecure server $ complete (Right unit)
  pure nonCanceler

pushAllowed :: ServerHttp2Stream -> Aff Boolean
pushAllowed = liftEffect <<< Server.pushAllowed

-- | Push a stream to the client, with the client request headers for a
-- | request which the client did not send but to which the server will respond.
-- |
-- | On the new pushed stream, it is mandatory to first call `respond`.
-- |
-- | Then call
-- | [`Node.Stream.Aff.write`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:write)
-- | and
-- | [`Node.Stream.Aff.end`](https://pursuit.purescript.org/packages/purescript-node-streams-aff/docs/Node.Stream.Aff#v:end).
-- |
-- | See [`http2stream.pushStream(headers[, options], callback)`](https://nodejs.org/docs/latest/api/http2.html#http2streampushstreamheaders-options-callback)
-- |
-- | > Calling `http2stream.pushStream()` from within a pushed stream is not permitted and will throw an error.
pushStream :: ServerHttp2Stream -> OptionsObject -> HeadersObject -> Aff ServerHttp2Stream
pushStream stream options headersRequest = makeAff \complete -> do
  Server.pushStream stream headersRequest options \nerr pushedstream _ -> do
    case toMaybe nerr of
      Just err -> complete (Left err)
      Nothing -> complete (Right pushedstream)
  pure nonCanceler

-- | Send an additional informational `HEADERS` frame to the connected HTTP/2 peer.
sendHeadersAdditional :: ServerHttp2Stream -> HeadersObject -> Aff Unit
sendHeadersAdditional stream headers = do
  liftEffect $ Server.additionalHeaders stream headers

-- | Wait for the end of the `Readable` request stream from the client.
-- | Maybe return
-- | trailing header fields (“trailers”) if found at the end of the stream.
-- |
-- | This `waitEnd` function must be called concurrently with `readAll`,
-- | for some reason related to the timing of the `'end'` event from Node’s
-- | `ServerHttp2Stream`.
-- | That’s not true for the `HTTP2.Client.Aff.waitEnd` function.
-- | It’s only necessary to call this function when you need the request
-- | trailing headers.
-- |
-- | ```
-- | parSequence_
-- |   [ do
-- |       trailers <- waitEnd stream
-- |   , do
-- |       buffers <- readAll (Server.Aff.toDuplex stream)
-- |   ]
-- | ```
waitEnd :: ServerHttp2Stream -> Aff (Maybe HeadersObject)
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
  waitTrailers :: ServerHttp2Stream -> Aff HeadersObject
  waitTrailers stream' = makeAff \complete -> do
    onceErrorStreamCancel <- Server.onceErrorStream stream' (complete <<< Left)
    onceTrailersCancel <- Server.onceTrailers stream' \headers _flags -> do
      onceErrorStreamCancel
      complete (Right headers)
    pure $ effectCanceler do
      onceErrorStreamCancel
      onceTrailersCancel

  -- | Wait for the end of the `Readable` stream from the server.
  waitEnd' :: ServerHttp2Stream -> Aff Unit
  waitEnd' stream' = makeAff \complete -> do
    readable <- Node.Stream.Aff.Internal.readable (toDuplex stream')
    if readable then do
      onceErrorStreamCancel <- Server.onceErrorStream stream' (complete <<< Left)
      onceEndCancel <- Server.onceEnd stream' $ complete (Right unit)
      pure $ effectCanceler do
        onceErrorStreamCancel
        onceEndCancel
    else do
      complete (Right unit)
      pure nonCanceler

-- | Close the server stream.
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
closeStream :: ServerHttp2Stream -> Int -> Aff Unit
closeStream stream code = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.closeStream stream code $ complete (Right unit)
  pure nonCanceler

-- | Wait for the
-- | [`wantTrailers`](https://nodejs.org/docs/latest/api/http2.html#event-wanttrailers)
-- | event.
-- |
-- | > When initiating a `request` or `response`, the `waitForTrailers` option must
-- | > be set for this event to be emitted.
-- |
-- | Follow this with a call to `sendTrailers`.
waitWantTrailers :: ServerHttp2Stream -> Aff Unit
waitWantTrailers stream = makeAff \complete -> do
  onceWantTrailersCancel <- Server.onceWantTrailers stream $ complete (Right unit)
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
sendTrailers :: ServerHttp2Stream -> HeadersObject -> Aff Unit
sendTrailers stream headers = makeAff \complete -> do
  catchException (complete <<< Left) do
    Server.sendTrailers stream headers
    complete (Right unit)
  pure nonCanceler
