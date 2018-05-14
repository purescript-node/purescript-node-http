-- | This module defines low-level bindings to the Node HTTPS module.

module Node.HTTP.Secure
  ( createServer

  , SSLOptions
  , handshakeTimeout
  , requestCert
  , rejectUnauthorized

  , NPNProtocols
  , npnProtocolsString
  , npnProtocolsBuffer
  , npnProtocolsUint8Array
  , npnProtocolsStringArray
  , npnProtocolsBufferArray
  , npnProtocolsUint8ArrayArray
  , npnProtocols

  , ALPNProtocols
  , alpnProtocolsString
  , alpnProtocolsBuffer
  , alpnProtocolsUint8Array
  , alpnProtocolsStringArray
  , alpnProtocolsBufferArray
  , alpnProtocolsUint8ArrayArray
  , alpnProtocols

  , sessionTimeout
  , ticketKeys

  , PFX
  , pfxString
  , pfxBuffer
  , pfx

  , Key
  , keyString
  , keyBuffer
  , keyStringArray
  , keyBufferArray
  , key

  , passphrase

  , Cert
  , certString
  , certBuffer
  , certStringArray
  , certBufferArray
  , cert

  , CA
  , caString
  , caBuffer
  , caStringArray
  , caBufferArray
  , ca

  , CRL
  , crlString
  , crlBuffer
  , crlStringArray
  , crlBufferArray
  , crl

  , ciphers
  , honorCipherOrder
  , ecdhCurve

  , DHParam
  , dhparamString
  , dhparamBuffer
  , dhparam

  , secureProtocol
  , secureOptions
  , sessionIdContext
  ) where

import Prelude

import Data.ArrayBuffer.Types (Uint8Array)
import Data.Options (Options, Option, options, opt)
import Effect (Effect)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.HTTP (Server, Request, Response)
import Unsafe.Coerce (unsafeCoerce)

-- | Create an HTTPS server, given the SSL options and a function to be executed
-- | when a request is received.
foreign import createServerImpl ::
  Foreign ->
  (Request -> Response -> Effect Unit) ->
  Effect Server

-- | Create an HTTPS server, given the SSL options and a function to be executed
-- | when a request is received.
createServer :: Options SSLOptions ->
                (Request -> Response -> Effect Unit) ->
                Effect Server
createServer = createServerImpl <<< options

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

-- | The npnProtocols option can be a String, a Buffer, a Uint8Array, or an
-- | array of any of those types.
data NPNProtocols
npnProtocolsString :: String -> NPNProtocols
npnProtocolsString = unsafeCoerce
npnProtocolsBuffer :: Buffer -> NPNProtocols
npnProtocolsBuffer = unsafeCoerce
npnProtocolsUint8Array :: Uint8Array -> NPNProtocols
npnProtocolsUint8Array = unsafeCoerce
npnProtocolsStringArray :: Array String -> NPNProtocols
npnProtocolsStringArray = unsafeCoerce
npnProtocolsBufferArray :: Array Buffer -> NPNProtocols
npnProtocolsBufferArray = unsafeCoerce
npnProtocolsUint8ArrayArray :: Array Uint8Array -> NPNProtocols
npnProtocolsUint8ArrayArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
npnProtocols :: Option SSLOptions NPNProtocols
npnProtocols = opt "NPNProtocols"

-- | The alpnProtocols option can be a String, a Buffer, a Uint8Array, or an
-- | array of any of those types.
data ALPNProtocols
alpnProtocolsString :: String -> ALPNProtocols
alpnProtocolsString = unsafeCoerce
alpnProtocolsBuffer :: Buffer -> ALPNProtocols
alpnProtocolsBuffer = unsafeCoerce
alpnProtocolsUint8Array :: Uint8Array -> ALPNProtocols
alpnProtocolsUint8Array = unsafeCoerce
alpnProtocolsStringArray :: Array String -> ALPNProtocols
alpnProtocolsStringArray = unsafeCoerce
alpnProtocolsBufferArray :: Array Buffer -> ALPNProtocols
alpnProtocolsBufferArray = unsafeCoerce
alpnProtocolsUint8ArrayArray :: Array Uint8Array -> ALPNProtocols
alpnProtocolsUint8ArrayArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
alpnProtocols :: Option SSLOptions ALPNProtocols
alpnProtocols = opt "ALPNProtocols"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
sessionTimeout :: Option SSLOptions Int
sessionTimeout = opt "sessionTimeout"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
ticketKeys :: Option SSLOptions Buffer
ticketKeys = opt "ticketKeys"

-- | The PFX option can take either a String or a Buffer
data PFX
pfxString :: String -> PFX
pfxString = unsafeCoerce
pfxBuffer :: Buffer -> PFX
pfxBuffer = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
pfx :: Option SSLOptions PFX
pfx = opt "pfx"

-- | The key option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data Key
keyString :: String -> Key
keyString = unsafeCoerce
keyBuffer :: Buffer -> Key
keyBuffer = unsafeCoerce
keyStringArray :: Array String -> Key
keyStringArray = unsafeCoerce
keyBufferArray :: Array Buffer -> Key
keyBufferArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
key :: Option SSLOptions Key
key = opt "key"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
passphrase :: Option SSLOptions String
passphrase = opt "passphrase"

-- | The cert option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data Cert
certString :: String -> Cert
certString = unsafeCoerce
certBuffer :: Buffer -> Cert
certBuffer = unsafeCoerce
certStringArray :: Array String -> Cert
certStringArray = unsafeCoerce
certBufferArray :: Array Buffer -> Cert
certBufferArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
cert :: Option SSLOptions Cert
cert = opt "cert"

-- | The CA option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data CA
caString :: String -> CA
caString = unsafeCoerce
caBuffer :: Buffer -> CA
caBuffer = unsafeCoerce
caStringArray :: Array String -> CA
caStringArray = unsafeCoerce
caBufferArray :: Array Buffer -> CA
caBufferArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ca :: Option SSLOptions CA
ca = opt "ca"

-- | The CRL option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data CRL
crlString :: String -> CRL
crlString = unsafeCoerce
crlBuffer :: Buffer -> CRL
crlBuffer = unsafeCoerce
crlStringArray :: Array String -> CRL
crlStringArray = unsafeCoerce
crlBufferArray :: Array Buffer -> CRL
crlBufferArray = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
crl :: Option SSLOptions CRL
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

-- | The DHParam option can take either a String or a Buffer
data DHParam
dhparamString :: String -> DHParam
dhparamString = unsafeCoerce
dhparamBuffer :: Buffer -> DHParam
dhparamBuffer = unsafeCoerce

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
dhparam :: Option SSLOptions DHParam
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
