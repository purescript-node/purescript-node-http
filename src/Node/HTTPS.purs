module Node.HTTPS
  ( CreateSecureServerOptions
  , createSecureServer
  , createSecureServer'
  , request
  , requestUrl
  , SecureRequestOptions
  , request'
  , requestURL'
  , requestOpts
  , get
  , getUrl
  , get'
  , getUrl'
  , getOpts
  ) where

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, runEffectFn1, runEffectFn2)
import Node.Buffer (Buffer)
import Node.HTTP (CreateServerOptions, RequestOptions)
import Node.HTTP.Types (ClientRequest, HttpServer', Encrypted)
import Node.TLS.Types as TLS
import Node.URL (URL)
import Prim.Row as Row

-- | Example usage. See `createSecureServer'` to pass in options:
-- |
-- | ```
-- | server <- HTTPS.createSecureServer
-- | -- setup request handler
-- | server # on Server.requestH \request response -> do
-- |   -- send back a response
-- | 
-- | -- (optional) setup listener callback
-- | let ns = Server.toNetServer server
-- | ns # once_ NetServer.listeningH do
-- | 
-- | -- start the server
-- | listenTcp ns { host: "localhost", port: 8000 }
-- | 
-- | -- Sometime in the future, close the server
-- | Server.closeAllConnections
-- | NetServer.close ns
-- | ```
foreign import createSecureServer :: Effect (HttpServer' Encrypted)

type CreateSecureServerOptions =
  TLS.TlsCreateServerOptions TLS.Server (TLS.CreateSecureContextOptions CreateServerOptions)

-- | Example usage:
-- |
-- | ```
-- | key' <- FSA.readFile "path/to/key/file"
-- | cert' <- FSA.readFile "path/to/cert/file"
-- | server <- HTTPS.createSecureServer'
-- |   { key: [ mockKey' ]
-- |   , cert: [ mockCert' ]
-- |   }
-- | -- setup request handler
-- | server # on Server.requestH \request response -> do
-- |   -- send back a response
-- | 
-- | -- (optional) setup listener callback
-- | let ns = Server.toNetServer server
-- | ns # once_ NetServer.listeningH do
-- | 
-- | -- start the server
-- | listenTcp ns { host: "localhost", port: 8000 }
-- | 
-- | -- Sometime in the future, close the server
-- | Server.closeAllConnections
-- | NetServer.close ns
-- | ```
createSecureServer'
  :: forall r trash
   . Row.Union r trash CreateSecureServerOptions
  => { | r }
  -> Effect (HttpServer' Encrypted)
createSecureServer' opts = runEffectFn1 createSecureServerOptsImpl opts

foreign import createSecureServerOptsImpl :: forall r. EffectFn1 ({ | r }) (HttpServer' Encrypted)

request :: String -> Effect ClientRequest
request url = runEffectFn1 requestStrImpl url

foreign import requestStrImpl :: EffectFn1 (String) (ClientRequest)

requestUrl :: URL -> Effect ClientRequest
requestUrl url = runEffectFn1 requestUrlImpl url

foreign import requestUrlImpl :: EffectFn1 (URL) (ClientRequest)

-- | - `ca` <string> | <string[]> | <Buffer> | <Buffer[]> Optionally override the trusted CA certificates. Default is to trust the well-known CAs curated by Mozilla. Mozilla's CAs are completely replaced when CAs are explicitly specified using this option. The value can be a string or Buffer, or an Array of strings and/or Buffers. Any string or Buffer can contain multiple PEM CAs concatenated together. The peer's certificate must be chainable to a CA trusted by the server for the connection to be authenticated. When using certificates that are not chainable to a well-known CA, the certificate's CA must be explicitly specified as a trusted or the connection will fail to authenticate. If the peer uses a certificate that doesn't match or chain to one of the default CAs, use the ca option to provide a CA certificate that the peer's certificate can match or chain to. For self-signed certificates, the certificate is its own CA, and must be provided. For PEM encoded certificates, supported types are "TRUSTED CERTIFICATE", "X509 CERTIFICATE", and "CERTIFICATE". See also tls.rootCertificates.
-- | - `cert` <string> | <string[]> | <Buffer> | <Buffer[]> Cert chains in PEM format. One cert chain should be provided per private key. Each cert chain should consist of the PEM formatted certificate for a provided private key, followed by the PEM formatted intermediate certificates (if any), in order, and not including the root CA (the root CA must be pre-known to the peer, see ca). When providing multiple cert chains, they do not have to be in the same order as their private keys in key. If the intermediate certificates are not provided, the peer will not be able to validate the certificate, and the handshake will fail.
-- | - `ciphers` <string> Cipher suite specification, replacing the default. For more information, see Modifying the default TLS cipher suite. Permitted ciphers can be obtained via tls.getCiphers(). Cipher names must be uppercased in order for OpenSSL to accept them.
-- | - `clientCertEngine` <string> Name of an OpenSSL engine which can provide the client certificate.
-- | - `crl` <string> | <string[]> | <Buffer> | <Buffer[]> PEM formatted CRLs (Certificate Revocation Lists).
-- | - `dhparam` <string> | <Buffer> 'auto' or custom Diffie-Hellman parameters, required for non-ECDHE perfect forward secrecy. If omitted or invalid, the parameters are silently discarded and DHE ciphers will not be available. ECDHE-based perfect forward secrecy will still be available.
-- | - `ecdhCurve` <string> A string describing a named curve or a colon separated list of curve NIDs or names, for example P-521:P-384:P-256, to use for ECDH key agreement. Set to auto to select the curve automatically. Use crypto.getCurves() to obtain a list of available curve names. On recent releases, openssl ecparam -list_curves will also display the name and description of each available elliptic curve. Default: tls.DEFAULT_ECDH_CURVE.
-- | - `honorCipherOrder` <boolean> Attempt to use the server's cipher suite preferences instead of the client's. When true, causes SSL_OP_CIPHER_SERVER_PREFERENCE to be set in secureOptions, see OpenSSL Options for more information.
-- | - `key` <string> | <string[]> | <Buffer> | <Buffer[]> | <Object[]> Private keys in PEM format. PEM allows the option of private keys being encrypted. Encrypted keys will be decrypted with options.passphrase. Multiple keys using different algorithms can be provided either as an array of unencrypted key strings or buffers, or an array of objects in the form {pem: <string|buffer>[, passphrase: <string>]}. The object form can only occur in an array. object.passphrase is optional. Encrypted keys will be decrypted with object.passphrase if provided, or options.passphrase if it is not.
-- | - `passphrase` <string> Shared passphrase used for a single private key and/or a PFX.
-- | - `pfx` <string> | <string[]> | <Buffer> | <Buffer[]> | <Object[]> PFX or PKCS12 encoded private key and certificate chain. pfx is an alternative to providing key and cert individually. PFX is usually encrypted, if it is, passphrase will be used to decrypt it. Multiple PFX can be provided either as an array of unencrypted PFX buffers, or an array of objects in the form {buf: <string|buffer>[, passphrase: <string>]}. The object form can only occur in an array. object.passphrase is optional. Encrypted PFX will be decrypted with object.passphrase if provided, or options.passphrase if it is not.
-- | - `rejectUnauthorized` <boolean> If not false the server will reject any connection which is not authorized with the list of supplied CAs. This option only has an effect if requestCert is true. Default: true.
-- | - `secureOptions` <number> Optionally affect the OpenSSL protocol behavior, which is not usually necessary. This should be used carefully if at all! Value is a numeric bitmask of the SSL_OP_* options from OpenSSL Options.
-- | - `secureProtocol` <string> Legacy mechanism to select the TLS protocol version to use, it does not support independent control of the minimum and maximum version, and does not support limiting the protocol to TLSv1.3. Use minVersion and maxVersion instead. The possible values are listed as SSL_METHODS, use the function names as strings. For example, use 'TLSv1_1_method' to force TLS version 1.1, or 'TLS_method' to allow any TLS protocol version up to TLSv1.3. It is not recommended to use TLS versions less than 1.2, but it may be required for interoperability. Default: none, see minVersion.
-- | - `sessionIdContext` <string> Opaque identifier used by servers to ensure session state is not shared between applications. Unused by clients.
-- | - `servername`: <string> Server name for the SNI (Server Name Indication) TLS extension. It is the name of the host being connected to, and must be a host name, and not an IP address. It can be used by a multi-homed server to choose the correct certificate to present to the client, see the SNICallback option to tls.createServer().
-- | - `highWaterMark`: <number> Consistent with the readable stream highWaterMark parameter. Default: 16 * 1024.
type SecureRequestOptions =
  ( ca :: Array Buffer
  , cert :: Array Buffer
  , ciphers :: String
  , clientCertEngine :: String
  , crl :: Array Buffer
  , dhparam :: Buffer
  , ecdhCurve :: String
  , honorCipherOrder :: Boolean
  , key :: Array Buffer
  , passphrase :: String
  , pfx :: Array Buffer
  , rejectUnauthorized :: Boolean
  , secureOptions :: Number
  , secureProtocol :: String
  , sessionIdContext :: String
  , servername :: String
  , highWaterMark :: Number
  | RequestOptions ()
  )

request'
  :: forall r trash
   . Row.Union r trash SecureRequestOptions
  => String
  -> { | r }
  -> Effect ClientRequest
request' url opts = runEffectFn2 requestStrOptsImpl url opts

foreign import requestStrOptsImpl :: forall r. EffectFn2 (String) ({ | r }) (ClientRequest)

requestURL'
  :: forall r trash
   . Row.Union r trash SecureRequestOptions
  => URL
  -> { | r }
  -> Effect ClientRequest
requestURL' url opts = runEffectFn2 requestUrlOptsImpl url opts

foreign import requestUrlOptsImpl :: forall r. EffectFn2 (URL) ({ | r }) (ClientRequest)

requestOpts
  :: forall r trash
   . Row.Union r trash SecureRequestOptions
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
   . Row.Union r trash SecureRequestOptions
  => Row.Lacks "method" r
  => String
  -> { | r }
  -> Effect ClientRequest
get' url opts = runEffectFn2 getStrOptsImpl url opts

foreign import getStrOptsImpl :: forall r. EffectFn2 (String) ({ | r }) (ClientRequest)

getUrl'
  :: forall r trash
   . Row.Union r trash SecureRequestOptions
  => Row.Lacks "method" r
  => URL
  -> { | r }
  -> Effect ClientRequest
getUrl' url opts = runEffectFn2 getUrlOptsImpl url opts

foreign import getUrlOptsImpl :: forall r. EffectFn2 (URL) ({ | r }) (ClientRequest)

getOpts
  :: forall r trash
   . Row.Union r trash SecureRequestOptions
  => { | r }
  -> Effect ClientRequest
getOpts opts = runEffectFn1 getOptsImpl opts

foreign import getOptsImpl :: forall r. EffectFn1 ({ | r }) (ClientRequest)
