module Node.HTTP
  ( CreateServerOptions
  , createServer
  , createServer'
  , maxHeaderSize
  , request
  , requestUrl
  , RequestOptions
  , request'
  , requestURL'
  , requestOpts
  , get
  , getUrl
  , get'
  , getUrl'
  , getOpts
  , setMaxIdleHttpParsers
  ) where

import Prelude

import Data.Time.Duration (Milliseconds)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.HTTP.Types (ClientRequest, HttpServer)
import Node.Net.Types (ConnectTcpOptions)
import Node.Stream (Duplex)
import Node.URL (URL)
import Prim.Row as Row

-- | - `connectionsCheckingInterval`: Sets the interval value in milliseconds to check for request and headers timeout in incomplete requests. Default: 30000.
-- | - `headersTimeout`: Sets the timeout value in milliseconds for receiving the complete HTTP headers from the client. See server.headersTimeout for more information. Default: 60000.
-- | - `highWaterMark` <number> Optionally overrides all sockets' readableHighWaterMark and writableHighWaterMark. This affects highWaterMark property of both IncomingMessage and ServerResponse. Default: See stream.getDefaultHighWaterMark().
-- | - `insecureHTTPParser` <boolean> Use an insecure HTTP parser that accepts invalid HTTP headers when true. Using the insecure parser should be avoided. See --insecure-http-parser for more information. Default: false.
-- | - `keepAlive` <boolean> If set to true, it enables keep-alive functionality on the socket immediately after a new incoming connection is received, similarly on what is done in [socket.setKeepAlive([enable][, initialDelay])][socket.setKeepAlive(enable, initialDelay)]. Default: false.
-- | - `keepAliveInitialDelay` <number> If set to a positive number, it sets the initial delay before the first keepalive probe is sent on an idle socket. Default: 0.
-- | - `requestTimeout`: Sets the timeout value in milliseconds for receiving the entire request from the client. See server.requestTimeout for more information. Default: 300000.
-- | - `joinDuplicateHeaders` <boolean> It joins the field line values of multiple headers in a request with , instead of discarding the duplicates. See message.headers for more information. Default: false.
-- | - `uniqueHeaders` <Array> A list of response headers that should be sent only once. If the header's value is an array, the items will be joined using ; .
type CreateServerOptions =
  ( connectionsCheckingInterval :: Milliseconds
  , headersTimeout :: Milliseconds
  , highWaterMark :: Number
  , insecureHTTPParser :: Boolean
  , keepAlive :: Boolean
  , keepAliveInitialDelay :: Milliseconds
  , requestTimeout :: Milliseconds
  , joinDuplicateHeaders :: Boolean
  , uniqueHeaders :: Array String
  )

foreign import createServer :: Effect (HttpServer)

createServer'
  :: forall r trash
   . Row.Union r trash CreateServerOptions
  => { | r }
  -> Effect HttpServer
createServer' opts = runEffectFn1 createServerOptsImpl opts

foreign import createServerOptsImpl :: forall r. EffectFn1 ({ | r }) (HttpServer)

foreign import maxHeaderSize :: Int

request :: String -> Effect ClientRequest
request url = runEffectFn1 requestStrImpl url

foreign import requestStrImpl :: EffectFn1 (String) (ClientRequest)

requestUrl :: URL -> Effect ClientRequest
requestUrl url = runEffectFn1 requestUrlImpl url

foreign import requestUrlImpl :: EffectFn1 (URL) (ClientRequest)

-- | - `auth` <string> Basic authentication ('user:password') to compute an Authorization header.
-- | - `createConnection` <Function> A function that produces a socket/stream to use for the request when the agent option is not used. This can be used to avoid creating a custom Agent class just to override the default createConnection function. See agent.createConnection() for more details. Any Duplex stream is a valid return value.
-- | - `defaultPort` <number> Default port for the protocol. Default: agent.defaultPort if an Agent is used, else undefined.
-- | - `family` <number> IP address family to use when resolving host or hostname. Valid values are 4 or 6. When unspecified, both IP v4 and v6 will be used.
-- | - `headers` <Object> An object containing request headers.
-- | - `hints` <number> Optional dns.lookup() hints.
-- | - `host` <string> A domain name or IP address of the server to issue the request to. Default: 'localhost'.
-- | - `hostname` <string> Alias for host. To support url.parse(), hostname will be used if both host and hostname are specified.
-- | - `insecureHTTPParser` <boolean> Use an insecure HTTP parser that accepts invalid HTTP headers when true. Using the insecure parser should be avoided. See --insecure-http-parser for more information. Default: false
-- | - `localAddress` <string> Local interface to bind for network connections.
-- | - `localPort` <number> Local port to connect from.
-- | - `lookup` <Function> Custom lookup function. Default: dns.lookup().
-- | - `maxHeaderSize` <number> Optionally overrides the value of --max-http-header-size (the maximum length of response headers in bytes) for responses received from the server. Default: 16384 (16 KiB).
-- | - `method` <string> A string specifying the HTTP request method. Default: 'GET'.
-- | - `path` <string> Request path. Should include query string if any. E.G. '/index.html?page=12'. An exception is thrown when the request path contains illegal characters. Currently, only spaces are rejected but that may change in the future. Default: '/'.
-- | - `port` <number> Port of remote server. Default: defaultPort if set, else 80.
-- | - `protocol` <string> Protocol to use. Default: 'http:'.
-- | - `setHost` <boolean>: Specifies whether or not to automatically add the Host header. Defaults to true.
-- | - `signal` <AbortSignal>: An AbortSignal that may be used to abort an ongoing request.
-- | - `socketPath` <string> Unix domain socket. Cannot be used if one of host or port is specified, as those specify a TCP Socket.
-- | - `timeout` <number>: A number specifying the socket timeout in milliseconds. This will set the timeout before the socket is connected.
-- | - `uniqueHeaders` <Array> A list of request headers that should be sent only once. If the header's value is an array, the items will be joined using ; .
-- | - `joinDuplicateHeaders` <boolean> It joins the field line values of multiple headers in a request with , instead of discarding the duplicates. See message.headers for more information. Default: false.
type RequestOptions r =
  ( auth :: String
  , createConnection :: Effect Duplex
  , defaultPort :: Int
  , family :: Int
  , headers :: Object Foreign
  , hints :: Number
  , host :: String
  , hostname :: String
  , insecureHTTPParser :: Boolean
  , localAddress :: String
  , localPort :: Int
  , maxHeaderSize :: Number
  , method :: String
  , path :: String
  , port :: Int
  , protocol :: String
  , setHost :: Boolean
  , socketPath :: String
  , timeout :: Milliseconds
  , uniqueHeaders :: Array String
  , joinDuplicateHeaders :: Boolean
  | ConnectTcpOptions r
  )

request'
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => String
  -> { | r }
  -> Effect ClientRequest
request' url opts = runEffectFn2 requestStrOptsImpl url opts

foreign import requestStrOptsImpl :: forall r. EffectFn2 (String) ({ | r }) (ClientRequest)

requestURL'
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => URL
  -> { | r }
  -> Effect ClientRequest
requestURL' url opts = runEffectFn2 requestUrlOptsImpl url opts

foreign import requestUrlOptsImpl :: forall r. EffectFn2 (URL) ({ | r }) (ClientRequest)

requestOpts
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => { | r }
  -> Effect ClientRequest
requestOpts opts = runEffectFn1 requestOptsImpl opts

foreign import requestOptsImpl :: forall r. EffectFn1 ({ | r }) (ClientRequest)

get :: String -> Effect ClientRequest
get url = runEffectFn1 getStrImpl url

foreign import getStrImpl :: EffectFn1 (String) (ClientRequest)

getUrl :: URL -> Effect ClientRequest
getUrl url = runEffectFn1 getUrlImpl url

foreign import getUrlImpl :: EffectFn1 (URL) (ClientRequest)

get'
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => Row.Lacks "method" r
  => String
  -> { | r }
  -> Effect ClientRequest
get' url opts = runEffectFn2 getStrOptsImpl url opts

foreign import getStrOptsImpl :: forall r. EffectFn2 (String) ({ | r }) (ClientRequest)

getUrl'
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => Row.Lacks "method" r
  => URL
  -> { | r }
  -> Effect ClientRequest
getUrl' url opts = runEffectFn2 getUrlOptsImpl url opts

foreign import getUrlOptsImpl :: forall r. EffectFn2 (URL) ({ | r }) (ClientRequest)

getOpts
  :: forall r trash
   . Row.Union r trash (RequestOptions ())
  => { | r }
  -> Effect ClientRequest
getOpts opts = runEffectFn1 getOptsImpl opts

foreign import getOptsImpl :: forall r. EffectFn1 ({ | r }) (ClientRequest)

setMaxIdleHttpParsers :: Int -> Effect Unit
setMaxIdleHttpParsers i = runEffectFn1 setMaxIdleHttpParsersImpl i

foreign import setMaxIdleHttpParsersImpl :: EffectFn1 (Int) (Unit)
