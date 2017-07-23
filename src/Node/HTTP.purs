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

-- | Abort the connection if the SSL/TLS handshake does not finish in the
-- | specified number of milliseconds. Defaults to 120 seconds. A
-- | 'tlsClientError' is emitted on the tls.Server object whenever a handshake
-- | times out.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
handshakeTimeout :: Option SSLOptions Int
handshakeTimeout = opt "handshakeTimeout"

-- | If true the server will request a certificate from clients that connect and
-- | attempt to verify that certificate. Defaults to false.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
requestCert :: Option SSLOptions Boolean
requestCert = opt "requestCert"

-- | If not false the server will reject any connection which is not authorized
-- | with the list of supplied CAs. This option only has an effect if
-- | requestCert is true. Defaults to true.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
rejectUnauthorized :: Option SSLOptions Boolean
rejectUnauthorized = opt "rejectUnauthorized"

-- | An array of strings, Buffers or Uint8Arrays, or a single Buffer or
-- | Uint8Array containing supported NPN protocols. Buffers should have the
-- | format [len][name][len][name]... e.g. 0x05hello0x05world, where the first
-- | byte is the length of the next protocol name. Passing an array is usually
-- | much simpler, e.g. ['hello', 'world']. (Protocols should be ordered by
-- | their priority.)
-- | The type variable t should be a string[], Buffer[], Uint8Array[], Buffer,
-- | or Uint8Array.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
npnProtocols :: forall t. Option SSLOptions t
npnProtocols = opt "NPNProtocols"

-- | An array of strings, Buffers or Uint8Arrays, or a single Buffer or
-- | Uint8Array containing the supported ALPN protocols. Buffers should have the
-- | format [len][name][len][name]... e.g. 0x05hello0x05world, where the first
-- | byte is the length of the next protocol name. Passing an array is usually
-- | much simpler, e.g. ['hello', 'world']. (Protocols should be ordered by
-- | their priority.) When the server receives both NPN and ALPN extensions from
-- | the client, ALPN takes precedence over NPN and the server does not send an
-- | NPN extension to the client.
-- | The type variable t should be a string[], Buffer[], Uint8Array[], Buffer,
-- | or Uint8Array.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
alpnProtocols :: forall t. Option SSLOptions t
alpnProtocols = opt "ALPNProtocols"

-- | An integer specifying the number of seconds after which the TLS session
-- | identifiers and TLS session tickets created by the server will time out.
-- | See SSL_CTX_set_timeout for more details.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
sessionTimeout :: Option SSLOptions Int
sessionTimeout = opt "sessionTimeout"

-- | A 48-byte Buffer instance consisting of a 16-byte prefix, a 16-byte HMAC
-- | key, and a 16-byte AES key. This can be used to accept TLS session tickets
-- | on multiple instances of the TLS server.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
ticketKeys :: Option SSLOptions Buffer
ticketKeys = opt "ticketKeys"

-- | Optional PFX or PKCS12 encoded private key and certificate chain. pfx is an
-- | alternative to providing key and cert individually. PFX is usually
-- | encrypted, if it is, passphrase will be used to decrypt it.
-- | The type variable t should be a string or Buffer.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
pfx :: forall t. Option SSLOptions t
pfx = opt "pfx"

-- | Optional private keys in PEM format. PEM allows the option of private keys
-- | being encrypted. Encrypted keys will be decrypted with options.passphrase.
-- | Multiple keys using different algorithms can be provided either as an array
-- | of unencrypted key strings or buffers, or an array of objects in the form
-- | {pem: <string|buffer>[, passphrase: <string>]}. The object form can only
-- | occur in an array. object.passphrase is optional. Encrypted keys will be
-- | decrypted with object.passphrase if provided, or options.passphrase if it
-- | is not.
-- | The type variable t should be a string, string[], Buffer, Buffer[], or
-- | Object[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
key :: forall t. Option SSLOptions t
key = opt "key"

-- | Optional shared passphrase used for a single private key and/or a PFX.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
passphrase :: Option SSLOptions String
passphrase = opt "passphrase"

-- | Optional cert chains in PEM format. One cert chain should be provided per
-- | private key. Each cert chain should consist of the PEM formatted
-- | certificate for a provided private key, followed by the PEM formatted
-- | intermediate certificates (if any), in order, and not including the root CA
-- | (the root CA must be pre-known to the peer, see ca). When providing
-- | multiple cert chains, they do not have to be in the same order as their
-- | private keys in key. If the intermediate certificates are not provided, the
-- | peer will not be able to validate the certificate, and the handshake will
-- | fail.
-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
cert :: forall t. Option SSLOptions t
cert = opt "cert"

-- | Optionally override the trusted CA certificates. Default is to trust the
-- | well-known CAs curated by Mozilla. Mozilla's CAs are completely replaced
-- | when CAs are explicitly specified using this option. The value can be a
-- | string or Buffer, or an Array of strings and/or Buffers. Any string or
-- | Buffer can contain multiple PEM CAs concatenated together. The peer's
-- | certificate must be chainable to a CA trusted by the server for the
-- | connection to be authenticated. When using certificates that are not
-- | chainable to a well-known CA, the certificate's CA must be explicitly
-- | specified as a trusted or the connection will fail to authenticate. If the
-- | peer uses a certificate that doesn't match or chain to one of the default
-- | CAs, use the ca option to provide a CA certificate that the peer's
-- | certificate can match or chain to. For self-signed certificates, the
-- | certificate is its own CA, and must be provided.
-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ca :: forall t. Option SSLOptions t
ca = opt "ca"

-- | Optional PEM formatted CRLs (Certificate Revocation Lists).
-- | The type variable t should be a string, string[], Buffer, or Buffer[].
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
crl :: forall t. Option SSLOptions t
crl = opt "crl"

-- | Optional cipher suite specification, replacing the default. For more
-- | information, see modifying the default cipher suite.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ciphers :: Option SSLOptions String
ciphers = opt "ciphers"

-- | Attempt to use the server's cipher suite preferences instead of the
-- | client's. When true, causes SSL_OP_CIPHER_SERVER_PREFERENCE to be set in
-- | secureOptions, see OpenSSL Options for more information.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
honorCipherOrder :: Option SSLOptions Boolean
honorCipherOrder = opt "honorCipherOrder"

-- | A string describing a named curve to use for ECDH key agreement or false to
-- | disable ECDH. Defaults to tls.DEFAULT_ECDH_CURVE. Use crypto.getCurves() to
-- | obtain a list of available curve names. On recent releases, openssl ecparam
-- | -list_curves will also display the name and description of each available
-- | elliptic curve.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ecdhCurve :: Option SSLOptions String
ecdhCurve = opt "ecdhCurve"

-- | Diffie Hellman parameters, required for Perfect Forward Secrecy. Use
-- | openssl dhparam to create the parameters. The key length must be greater
-- | than or equal to 1024 bits, otherwise an error will be thrown. It is
-- | strongly recommended to use 2048 bits or larger for stronger security. If
-- | omitted or invalid, the parameters are silently discarded and DHE ciphers
-- | will not be available.
-- | The type variable t should be a string or Buffer.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
dhparam :: forall t. Option SSLOptions t
dhparam = opt "dhparam"

-- | Optional SSL method to use, default is "SSLv23_method". The possible values
-- | are listed as SSL_METHODS, use the function names as strings. For example,
-- | "SSLv3_method" to force SSL version 3.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureProtocol :: Option SSLOptions String
secureProtocol = opt "secureProtocol"

-- | Optionally affect the OpenSSL protocol behavior, which is not usually
-- | necessary. This should be used carefully if at all! Value is a numeric
-- | bitmask of the SSL_OP_* options from OpenSSL Options.
-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureOptions :: Option SSLOptions Int
secureOptions = opt "secureOptions"

-- | Optional opaque identifier used by servers to ensure session state is not
-- | shared between applications. Unused by clients.
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
