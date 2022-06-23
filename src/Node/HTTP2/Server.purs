-- | Low-level bindings to the *Node.js* HTTP/2 Server Core API.
-- |
-- | ## Server-side example
-- |
-- | Equivalent to
-- | https://nodejs.org/docs/latest/api/http2.html#server-side-example
-- |
-- | ```
-- | key <- Node.FS.Sync.readFile "localhost-privkey.pem"
-- | cert <- Node.FS.Sync.readFile "localhost-cert.pem"
-- |
-- | server <- createSecureServer (toOptions {key, cert})
-- | _ <- onErrorServerSecure server Console.errorShow
-- |
-- | _ <- onceStreamSecure server \stream headers flags -> do
-- |   respond stream
-- |     (toHeaders
-- |       { "content-type": "text/html; charset=utf-8"
-- |       , ":status": 200
-- |       }
-- |     )
-- |     (toOptions {})
-- |   void $ Node.Stream.writeString (toDuplex stream)
-- |     Node.Encoding.UTF8
-- |     "<h1>Hello World</h1>"
-- |     (\_ -> pure unit)
-- |   Node.Stream.end (toDuplex stream) (\_ -> pure unit)
-- |
-- | listenSecure server
-- |   (toOptions { port: 8443 })
-- |   (pure unit)
-- | ```
module Node.HTTP2.Server
  ( Http2Server
  , createServer
  , listen
  , onceSession
  , onStream
  , onceStream
  , onErrorServer
  , closeServer
  , onceCloseServer
  , Http2SecureServer
  , createSecureServer
  , listenSecure
  , onceSessionSecure
  , onStreamSecure
  , onceStreamSecure
  , onErrorServerSecure
  , closeServerSecure
  , onceCloseServerSecure
  , ServerHttp2Session
  , respond
  , localSettings
  , closeSession
  , ServerHttp2Stream
  , session
  , onceErrorStream
  , pushAllowed
  , pushStream
  , onceTrailers
  , additionalHeaders
  , onceWantTrailers
  , sendTrailers
  , onceEnd
  , toDuplex
  , closeStream
  ) where

import Prelude

import Data.Nullable (Nullable)
import Effect (Effect)
import Effect.Exception (Error)
import Node.HTTP2 (Flags, HeadersObject, OptionsObject, SettingsObject)
import Node.HTTP2.Internal as Internal
import Node.Stream (Duplex)
import Unsafe.Coerce (unsafeCoerce)

-- | An HTTP/2 server with one listening socket for unencrypted connections.
-- |
-- | See [__Class: Http2Server__](https://nodejs.org/docs/latest/api/http2.html#class-http2server)
foreign import data Http2Server :: Type

-- | https://nodejs.org/docs/latest/api/http2.html#http2createserveroptions-onrequesthandler
foreign import createServer :: OptionsObject -> Effect Http2Server

-- | https://nodejs.org/docs/latest/api/net.html#serverlistenoptions-callback
foreign import listen :: Http2Server -> OptionsObject -> Effect Unit -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#serverclosecallback
closeServer :: Http2Server -> Effect Unit -> Effect Unit
closeServer = unsafeCoerce Internal.closeServer

-- | https://nodejs.org/docs/latest/api/net.html#event-close
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceCloseServer :: Http2Server -> Effect Unit -> Effect (Effect Unit)
onceCloseServer = unsafeCoerce Internal.onceServerClose

-- | An HTTP/2 server with one listening socket for encrypted connections.
-- |
-- | See [__Class: Http2SecureServer__](https://nodejs.org/docs/latest/api/http2.html#class-http2secureserver)
foreign import data Http2SecureServer :: Type

-- | https://nodejs.org/docs/latest/api/http2.html#http2createsecureserveroptions-onrequesthandler
-- |
-- | Required options: `key :: String`, `cert :: String`.
foreign import createSecureServer :: OptionsObject -> Effect Http2SecureServer

-- | https://nodejs.org/docs/latest/api/net.html#serverlistenoptions-callback
listenSecure :: Http2SecureServer -> OptionsObject -> Effect Unit -> Effect Unit
listenSecure = unsafeCoerce listen

-- | https://nodejs.org/docs/latest/api/http2.html#serverclosecallback
closeServerSecure :: Http2SecureServer -> Effect Unit -> Effect Unit
closeServerSecure = unsafeCoerce Internal.closeServer

-- | https://nodejs.org/docs/latest/api/net.html#event-close
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceCloseServerSecure :: Http2SecureServer -> Effect Unit -> Effect (Effect Unit)
onceCloseServerSecure = unsafeCoerce Internal.onceServerClose

-- | https://nodejs.org/docs/latest/api/net.html#event-error
-- |
-- |  the 'close' event will not be emitted directly following this event unless server.close() is manually called.
-- |
-- | Returns an effect for removing the event listener.
onErrorServer :: Http2Server -> (Error -> Effect Unit) -> Effect (Effect Unit)
onErrorServer = unsafeCoerce Internal.onEmitterError

-- | https://nodejs.org/docs/latest/api/net.html#event-error
-- |
-- |  the 'close' event will not be emitted directly following this event unless server.close() is manually called.
-- |
-- | Returns an effect for removing the event listener.
onErrorServerSecure :: Http2SecureServer -> (Error -> Effect Unit) -> Effect (Effect Unit)
onErrorServerSecure = unsafeCoerce Internal.onEmitterError

-- | https://nodejs.org/docs/latest/api/http2.html#class-serverhttp2session
-- |
-- | > Every `Http2Session` instance is associated with exactly one
-- | > `net.Socket` or `tls.TLSSocket` when it is created. When either
-- | > the `Socket` or the `Http2Session` are destroyed, both will be destroyed.
-- |
-- | > On the server side, user code should rarely have occasion to work
-- | > with the `Http2Session` object directly, with most actions typically
-- | > taken through interactions with either the `Http2Server` or `Http2Stream` objects.
foreign import data ServerHttp2Session :: Type

session :: ServerHttp2Stream -> ServerHttp2Session
session = unsafeCoerce Internal.session

-- | https://nodejs.org/docs/latest/api/http2.html#event-session
-- |
-- | Listen for one event, call the callback, then remove
-- | the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
foreign import onceSession :: Http2Server -> (ServerHttp2Session -> Effect Unit) -> Effect (Effect Unit)

-- | https://nodejs.org/api/http2.html#http2sessionlocalsettings
localSettings :: ServerHttp2Session -> Effect SettingsObject
localSettings = unsafeCoerce Internal.localSettings

-- | https://nodejs.org/docs/latest/api/http2.html#http2sessionclosecallback
closeSession :: ServerHttp2Session -> Effect Unit -> Effect Unit
closeSession = unsafeCoerce Internal.closeSession

-- | Listen for one event, call the callback, then remove
-- | the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
onceStream :: Http2Server -> (ServerHttp2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onceStream = unsafeCoerce Internal.onceStream

-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
-- |
-- | Returns an effect for removing the event listener.
onStream :: Http2Server -> (ServerHttp2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onStream = unsafeCoerce Internal.onStream

-- | Listen for one event, call the callback, then remove
-- | the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
onceStreamSecure :: Http2SecureServer -> (ServerHttp2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onceStreamSecure = unsafeCoerce Internal.onceStream

-- | https://nodejs.org/docs/latest/api/http2.html#event-stream
-- |
-- | Returns an effect for removing the event listener.
onStreamSecure :: Http2SecureServer -> (ServerHttp2Stream -> HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onStreamSecure = unsafeCoerce Internal.onStream

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamrespondheaders-options
respond :: ServerHttp2Stream -> HeadersObject -> OptionsObject -> Effect Unit
respond = unsafeCoerce Internal.respond

-- | https://nodejs.org/docs/latest/api/http2.html#event-session_1
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceSessionSecure :: Http2SecureServer -> (ServerHttp2Session -> Effect Unit) -> Effect Unit
onceSessionSecure = unsafeCoerce onceSession

-- | An HTTP/2 server `Http2Stream` connected to a client.
-- |
-- | See [__Class: ServerHttp2Stream__](https://nodejs.org/docs/latest/api/http2.html#class-serverhttp2stream)
foreign import data ServerHttp2Stream :: Type

-- | https://nodejs.org/docs/latest/api/http2.html#http2streampushallowed
foreign import pushAllowed :: ServerHttp2Stream -> Effect Boolean

-- | https://nodejs.org/docs/latest/api/http2.html#http2streampushstreamheaders-options-callback
-- |
-- | > Calling `http2stream.pushStream()` from within a pushed stream is not permitted and will throw an error.
-- |
-- | https://www.rfc-editor.org/rfc/rfc7540#section-8.2.1
foreign import pushStream :: ServerHttp2Stream -> HeadersObject -> OptionsObject -> (Nullable Error -> ServerHttp2Stream -> HeadersObject -> Effect Unit) -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#event-trailers
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceTrailers :: ServerHttp2Stream -> (HeadersObject -> Flags -> Effect Unit) -> Effect (Effect Unit)
onceTrailers = unsafeCoerce Internal.onceTrailers

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamadditionalheadersheaders
foreign import additionalHeaders :: ServerHttp2Stream -> HeadersObject -> Effect Unit

-- | https://nodejs.org/docs/latest/api/http2.html#event-error_1
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceErrorStream :: ServerHttp2Stream -> (Error -> Effect Unit) -> Effect (Effect Unit)
onceErrorStream = unsafeCoerce Internal.onceEmitterError

-- | https://nodejs.org/docs/latest/api/http2.html#event-wanttrailers
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceWantTrailers :: ServerHttp2Stream -> Effect Unit -> Effect (Effect Unit)
onceWantTrailers = unsafeCoerce Internal.onceWantTrailers

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamsendtrailersheaders
-- |
-- | > When sending a request or sending a response, the `options.waitForTrailers` option must be set in order to keep the `Http2Stream` open after the final `DATA` frame so that trailers can be sent.
sendTrailers :: ServerHttp2Stream -> HeadersObject -> Effect Unit
sendTrailers = unsafeCoerce Internal.sendTrailers

-- | https://nodejs.org/docs/latest/api/net.html#event-end
-- |
-- | Listen for one event, then remove the event listener.
-- |
-- | Returns an effect for removing the event listener before the event
-- | is raised.
onceEnd :: ServerHttp2Stream -> Effect Unit -> Effect (Effect Unit)
onceEnd = unsafeCoerce Internal.onceEnd

-- | https://nodejs.org/docs/latest/api/http2.html#http2streamclosecode-callback
closeStream :: ServerHttp2Stream -> Int -> Effect Unit -> Effect Unit
closeStream stream code = Internal.closeStream (unsafeCoerce stream) code

-- | Coerce to a duplex stream.
toDuplex :: ServerHttp2Stream -> Duplex
toDuplex = unsafeCoerce
