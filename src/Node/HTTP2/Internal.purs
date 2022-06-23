-- | Internals. You should not need to import anything from this module.
-- | If you need to import something from this module then please open an
-- | issue about that.
module Node.HTTP2.Internal where

import Prelude

import Effect (Effect)
import Effect.Exception (Error)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP2 (Flags, HeadersObject, OptionsObject, SettingsObject)
import Node.HTTP2.Constants (NGHTTP2)

-- | Private type which can be coerced into `ClientHttp2Session`
-- | or `ServerHttp2Session`.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#class-http2session
-- |
-- | > Every `Http2Session` instance is associated with exactly one
-- | > `net.Socket` or `tls.TLSSocket` when it is created. When either
-- | > the `Socket` or the `Http2Session` are destroyed, both will be destroyed.
foreign import data Http2Session :: Type

-- | https://nodejs.org/api/http2.html#http2sessionlocalsettings
foreign import localSettings :: Http2Session -> Effect SettingsObject

-- | Listen for one event, call the callback, then remove
-- | the event listener.
-- | Returns an effect for removing the event listener before the event
-- | is raised.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
foreign import onceStream :: Foreign -> (Http2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
foreign import onStream :: Foreign -> (Http2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | Listen for one NodeEventTarget `'error'`, call the callback, then remove
-- | the event listener.
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceError :: Foreign -> (Error -> Effect Unit) -> Effect (Effect Unit)

-- | Listen for one EventEmitter `'error'`, call the callback, then remove
-- | the event listener.
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceEmitterError :: Foreign -> (Error -> Effect Unit) -> Effect (Effect Unit)

-- | EventEmitter `on 'error'`
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onEmitterError :: Foreign -> (Error -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback
foreign import closeSession :: Http2Session -> Effect Unit -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#serverclosecallback
foreign import closeServer :: Foreign -> Effect Unit -> Effect Unit

-- | https://nodejs.org/docs/latest/api/net.html#event-close
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceServerClose :: Foreign -> Effect Unit -> Effect (Effect Unit)

-- | To an `EventTarget` attach an `'error'` listener which will always throw
-- | a synchronous `Error`.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#error-handling
-- |
-- | > (Errors) will be reported using either a synchronous throw or via
-- | > an 'error' event on the `Http2Stream`, `Http2Session` or
-- | > `Http2Server` objects, depending on where and when the error occurs.
-- |
-- | https://nodejs.org/api/events.html#eventtargetaddeventlistenertype-listener-options
foreign import throwAllErrors :: Foreign -> Effect Unit

-- | Private type which can be coerced into ClientHttp2Stream
-- | or ServerHttp2Stream or Duplex.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#class-http2stream
foreign import data Http2Stream :: Type

-- | https://nodejs.org/docs/latest/api/http2.html#event-close_1
foreign import onceClose :: Http2Stream -> (NGHTTP2 -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamrespondheaders-options
foreign import respond :: Http2Stream -> HeadersObject -> OptionsObject -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#event-wanttrailers
foreign import onceWantTrailers :: Http2Stream -> Effect Unit -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamsendtrailersheaders
foreign import sendTrailers :: Http2Stream -> HeadersObject -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#event-trailers
foreign import onceTrailers :: Http2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/stream.html#event-data
foreign import onData :: Http2Stream -> (Buffer -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/docs/latest/api/net.html#event-end
foreign import onceEnd :: Http2Stream -> Effect Unit -> Effect (Effect Unit)

-- | https://nodejs.org/api/http2.html#http2streamsession
foreign import session :: Http2Stream -> Http2Session

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamclosecode-callback
foreign import closeStream :: Http2Stream -> Int -> Effect Unit -> Effect Unit
