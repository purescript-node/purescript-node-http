-- | This module defines low-level bindings to the Node HTTP module.

module Node.HTTP
  ( Server
  , Request
  , Response
  , HTTP

  , createServerS
  , SSLOptions
  , handshakeTimeout
  , requestCert
  , rejectUnauthorized
  , npnProtocols
  , alpnProtocols
  , sessionTimeout
  , ticketKeys
  , pfx
  , key
  , passphrase
  , cert
  , ca
  , crl
  , ciphers
  , honorCipherOrder
  , ecdhCurve
  , dhparam
  , secureProtocol
  , secureOptions
  , sessionIdContext

  , createServer
  , listen
  , ListenOptions
  , listenSocket

  , httpVersion
  , requestHeaders
  , requestMethod
  , requestURL
  , requestAsStream

  , setHeader
  , setHeaders
  , setStatusCode
  , setStatusMessage
  , responseAsStream
  ) where

import Prelude

import Control.Monad.Eff (Eff, kind Effect)

import Data.Foreign (Foreign)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.Options (Options, Option, options, opt)
import Data.StrMap (StrMap)

import Node.Buffer (Buffer)
import Node.Stream (Writable, Readable)

import Unsafe.Coerce (unsafeCoerce)

-- | The type of a HTTP server object
foreign import data Server :: Type

-- | A HTTP request object
foreign import data Request :: Type

-- | A HTTP response object
foreign import data Response :: Type

-- | The effect associated with using the HTTP module.
foreign import data HTTP :: Effect

-- | Create a HTTP server, given a function to be executed when a request is received.
foreign import createServer :: forall eff. (Request -> Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Server

-- | The type of HTTPS server options
data SSLOptions

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
handshakeTimeout :: Option SSLOptions Int
handshakeTimeout = opt "handshakeTimeout"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
requestCert :: Option SSLOptions Boolean
requestCert = opt "requestCert"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
rejectUnauthorized :: Option SSLOptions Boolean
rejectUnauthorized = opt "rejectUnauthorized"

-- | The type variable t should be a string[], Buffer[], Uint8Array[], Buffer,
-- | or Uint8Array.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
npnProtocols :: forall t. Option SSLOptions t
npnProtocols = opt "NPNProtocols"

-- | The type variable t should be a string[], Buffer[], Uint8Array[], Buffer,
-- | or Uint8Array.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
alpnProtocols :: forall t. Option SSLOptions t
alpnProtocols = opt "ALPNProtocols"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
sessionTimeout :: Option SSLOptions Int
sessionTimeout = opt "sessionTimeout"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
ticketKeys :: Option SSLOptions Buffer
ticketKeys = opt "ticketKeys"

-- | The type variable t should be a string or Buffer.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
pfx :: forall t. Option SSLOptions t
pfx = opt "pfx"

-- | The type variable t should be a string, string[], Buffer, Buffer[], or
-- | Object[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
key :: forall t. Option SSLOptions t
key = opt "key"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
passphrase :: Option SSLOptions String
passphrase = opt "passphrase"

-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
cert :: forall t. Option SSLOptions t
cert = opt "cert"

-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ca :: forall t. Option SSLOptions t
ca = opt "ca"

-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
crl :: forall t. Option SSLOptions t
crl = opt "crl"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ciphers :: Option SSLOptions String
ciphers = opt "ciphers"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
honorCipherOrder :: Option SSLOptions Boolean
honorCipherOrder = opt "honorCipherOrder"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ecdhCurve :: Option SSLOptions String
ecdhCurve = opt "ecdhCurve"

-- | The type variable t should be a string or Buffer.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
dhparam :: forall t. Option SSLOptions t
dhparam = opt "dhparam"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureProtocol :: Option SSLOptions String
secureProtocol = opt "secureProtocol"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureOptions :: Option SSLOptions Int
secureOptions = opt "secureOptions"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
sessionIdContext :: Option SSLOptions String
sessionIdContext = opt "sessionIdContext"

foreign import createServerSImpl ::
  forall eff.
  Foreign ->
  (Request -> Response -> Eff (http :: HTTP | eff) Unit) ->
  Eff (http :: HTTP | eff) Server

-- | Create an HTTPS server, given the SSL options and a function to be executed
-- | when a request is received.
createServerS :: forall eff.
                 Options SSLOptions ->
                 (Request -> Response -> Eff (http :: HTTP | eff) Unit) ->
                 Eff (http :: HTTP | eff) Server
createServerS = createServerSImpl <<< options

foreign import listenImpl :: forall eff. Server -> Int -> String -> Nullable Int -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit

-- | Listen on a port in order to start accepting HTTP requests. The specified callback will be run when setup is complete.
listen :: forall eff. Server -> ListenOptions -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit
listen server opts done = listenImpl server opts.port opts.hostname (toNullable opts.backlog) done

-- | Options to be supplied to `listen`. See the [Node API](https://nodejs.org/dist/latest-v6.x/docs/api/http.html#http_server_listen_handle_callback) for detailed information about these.
type ListenOptions =
  { hostname :: String
  , port :: Int
  , backlog :: Maybe Int
  }

-- | Listen on a unix socket. The specified callback will be run when setup is complete.
foreign import listenSocket :: forall eff. Server -> String -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit

-- | Get the request HTTP version
httpVersion :: Request -> String
httpVersion = _.httpVersion <<< unsafeCoerce

-- | Get the request headers as a hash
requestHeaders :: Request -> StrMap String
requestHeaders = _.headers <<< unsafeCoerce

-- | Get the request method (GET, POST, etc.)
requestMethod :: Request -> String
requestMethod = _.method <<< unsafeCoerce

-- | Get the request URL
requestURL :: Request -> String
requestURL = _.url <<< unsafeCoerce

-- | Coerce the request object into a readable stream.
requestAsStream :: forall eff. Request -> Readable () (http :: HTTP | eff)
requestAsStream = unsafeCoerce

-- | Set a header with a single value.
foreign import setHeader :: forall eff. Response -> String -> String -> Eff (http :: HTTP | eff) Unit

-- | Set a header with multiple values.
foreign import setHeaders :: forall eff. Response -> String -> Array String -> Eff (http :: HTTP | eff) Unit

-- | Set the status code.
foreign import setStatusCode :: forall eff. Response -> Int -> Eff (http :: HTTP | eff) Unit

-- | Set the status message.
foreign import setStatusMessage :: forall eff. Response -> String -> Eff (http :: HTTP | eff) Unit

-- | Coerce the response object into a writable stream.
responseAsStream :: forall eff. Response -> Writable () (http :: HTTP | eff)
responseAsStream = unsafeCoerce
