-- | Low-level bindings to the *Node.js* HTTP/2 Client Core API.
-- |
-- | ## Client-side example
-- |
-- | Equivalent to
-- | https://nodejs.org/docs/latest/api/http2.html#client-side-example
-- |
-- | ```
-- | ca <- Node.FS.Sync.readFile "localhost-cert.pem"
-- |
-- | client <- connect
-- |   (URL.parse "https://localhost:8443")
-- |   (toOptions {ca})
-- |   (\_ _ -> pure unit)
-- | _ <- onceErrorSession client Console.errorShow
-- |
-- | req <- request client
-- |   (toHeaders {":path": "/"})
-- |   (toOptions {})
-- |
-- | _ <- onceResponse req
-- |   \headers flags ->
-- |     for_ (headerKeys headers) \name ->
-- |       Console.log $
-- |         name <> ": " <> fromMaybe "" (headerValueString headers name)
-- |
-- | dataRef <- liftST $ Control.Monad.ST.Ref.new ""
-- | Node.Stream.onDataString (toDuplex req) Node.Encoding.UTF8
-- |   \chunk -> void $ liftST $
-- |     Control.Monad.ST.Ref.modify (_ <> chunk) dataRef
-- | Node.Stream.onEnd (toDuplex req) do
-- |   dataString <- liftST $ Control.Monad.ST.Ref.read dataRef
-- |   Console.log $ "\n" <> dataString
-- |   close client
-- | ```
module Node.HTTP2.Client
  ( ClientHttp2Session
  , connect
  , connectWithError
  , onceReady
  , request
  , onceErrorSession
  , onceResponse
  , onceStream
  , onceHeaders
  , closeSession
  , ClientHttp2Stream
  , oncePush
  , onceErrorStream
  , toDuplex
  , onceTrailers
  , onceWantTrailers
  , sendTrailers
  , onData
  , onceEnd
  , destroy
  , closeStream
  ) where

import Prelude

import Effect (Effect)
import Effect.Exception (Error)
import Node.Buffer (Buffer)
import Node.HTTP2 (Flags, HeadersObject, OptionsObject)
import Node.HTTP2.Internal (Http2Session, Http2Stream)
import Node.HTTP2.Internal as Internal
import Node.Net.Socket (Socket)
import Node.Stream (Duplex)
import Node.URL (URL)
import Unsafe.Coerce (unsafeCoerce)

-- | > Every `Http2Session` instance is associated with exactly one `net.Socket` or `tls.TLSSocket` when it is created. When either the `Socket` or the `Http2Session` are destroyed, both will be destroyed.
-- |
-- | See [__Class: ClientHttp2Session__](https://nodejs.org/docs/latest/api/http2.html#class-clienthttp2session)
foreign import data ClientHttp2Session :: Type

upcastClientHttp2Session :: ClientHttp2Session -> Http2Session
upcastClientHttp2Session = unsafeCoerce

-- | https://nodejs.org/docs/latest/api/http2.html#http2connectauthority-options-listener
foreign import connect :: URL -> OptionsObject -> (ClientHttp2Session -> Socket -> Effect Unit) -> Effect ClientHttp2Session

-- | https://stackoverflow.com/questions/67790720/node-js-net-connect-error-in-spite-of-try-catch
foreign import connectWithError :: URL -> OptionsObject -> (ClientHttp2Session -> Socket -> Effect Unit) -> (Error -> Effect Unit) -> Effect ClientHttp2Session

-- | https://nodejs.org/api/net.html#event-ready
foreign import onceReady :: Socket -> (Effect Unit) -> Effect (Effect Unit)

-- | A client-side `Http2Stream`.
-- |
-- | See [__Class: ClientHttp2Stream__](https://nodejs.org/docs/latest/api/http2.html#class-clienthttp2stream)
foreign import data ClientHttp2Stream :: Type

upcastClientHttp2Stream :: ClientHttp2Stream -> Http2Stream
upcastClientHttp2Stream = unsafeCoerce

-- |https://nodejs.org/docs/latest/api/http2.html#clienthttp2sessionrequestheaders-options
foreign import request :: ClientHttp2Session -> HeadersObject -> OptionsObject -> Effect ClientHttp2Stream

-- | https://nodejs.org/docs/latest/api/http2.html#destruction
foreign import destroy :: ClientHttp2Stream -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback
closeSession :: ClientHttp2Session -> Effect Unit -> Effect Unit
closeSession http2session = Internal.closeSession (upcastClientHttp2Session http2session)

-- | https://nodejs.org/docs/latest/api/http2.html#event-response
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceResponse :: ClientHttp2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#event-headers
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceHeaders :: ClientHttp2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#push-streams-on-the-client
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
-- | is raised.
foreign import onceStream :: ClientHttp2Session -> (ClientHttp2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#event-error
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceErrorSession :: ClientHttp2Session -> (Error -> Effect Unit) -> Effect (Effect Unit)
onceErrorSession http2session = Internal.onceSessionEmitterError (upcastClientHttp2Session http2session)

-- | https://nodejs.org/docs/latest/api/http2.html#event-error_1
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceErrorStream :: ClientHttp2Stream -> (Error -> Effect Unit) -> Effect (Effect Unit)
onceErrorStream http2stream = Internal.onceStreamEmitterError (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/http2.html#event-push
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#push-streams-on-the-client
foreign import oncePush :: ClientHttp2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#event-trailers
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceTrailers :: ClientHttp2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onceTrailers http2stream = Internal.onceTrailers (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/http2.html#event-wanttrailers
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceWantTrailers :: ClientHttp2Stream -> Effect Unit -> Effect (Effect Unit)
onceWantTrailers http2stream = Internal.onceWantTrailers (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamsendtrailersheaders
-- |
-- | > When sending a request or sending a response, the `options.waitForTrailers` option must be set in order to keep the `Http2Stream` open after the final `DATA` frame so that trailers can be sent.
sendTrailers :: ClientHttp2Stream -> HeadersObject -> Effect Unit
sendTrailers http2stream = Internal.sendTrailers (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/stream.html#event-data
-- |
-- | Returns an effect for removing the event listener.
onData :: ClientHttp2Stream -> (Buffer -> Effect Unit) -> Effect (Effect Unit)
onData http2stream = Internal.onData (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/net.html#event-end
-- |
-- | Listen for one event, call the callback, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceEnd :: ClientHttp2Stream -> Effect Unit -> Effect (Effect Unit)
onceEnd http2stream = Internal.onceEnd (upcastClientHttp2Stream http2stream)

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamclosecode-callback
closeStream :: ClientHttp2Stream -> Int -> Effect Unit -> Effect Unit
closeStream stream = Internal.closeStream (upcastClientHttp2Stream stream)

-- | Coerce to a duplex stream.
toDuplex :: ClientHttp2Stream -> Duplex
toDuplex = unsafeCoerce
