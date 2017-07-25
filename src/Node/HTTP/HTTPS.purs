-- | This module defines low-level bindings to the Node HTTPS module.

module Node.HTTP.HTTPS
  ( createServer

  , SSLOptions
  , handshakeTimeout
  , requestCert
  , rejectUnauthorized
  , NPNProtocols(..)
  , npnProtocols
  , ALPNProtocols(..)
  , alpnProtocols
  , sessionTimeout
  , ticketKeys
  , PFX(..)
  , pfx
  , Key(..)
  , key
  , passphrase
  , Cert(..)
  , cert
  , CA(..)
  , ca
  , CRL(..)
  , crl
  , ciphers
  , honorCipherOrder
  , ecdhCurve
  , DHParam(..)
  , dhparam
  , secureProtocol
  , secureOptions
  , sessionIdContext
  ) where

import Prelude

import Control.Monad.Eff (Eff)
import Data.ArrayBuffer.Types (Uint8Array)
import Data.Foreign (Foreign, toForeign)
import Data.Functor.Contravariant (cmap)
import Data.Options (Options, Option, options, opt)
import Node.Buffer (Buffer)
import Node.HTTP (Request, Response, Server, HTTP)

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
  = NPNProtocolsString String
  | NPNProtocolsBuffer Buffer
  | NPNProtocolsUint8Array Uint8Array
  | NPNProtocolsStringArray (Array String)
  | NPNProtocolsBufferArray (Array Buffer)
  | NPNProtocolsUint8ArrayArray (Array Uint8Array)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
npnProtocols :: Option SSLOptions NPNProtocols
npnProtocols = cmap extract $ opt "NPNProtocols"
  where
    extract (NPNProtocolsString s) = toForeign s
    extract (NPNProtocolsBuffer b) = toForeign b
    extract (NPNProtocolsUint8Array u) = toForeign u
    extract (NPNProtocolsStringArray sa) = toForeign sa
    extract (NPNProtocolsBufferArray ba) = toForeign ba
    extract (NPNProtocolsUint8ArrayArray ua) = toForeign ua

-- | The alpnProtocols option can be a String, a Buffer, a Uint8Array, or an
-- | array of any of those types.
data ALPNProtocols
  = ALPNProtocolsString String
  | ALPNProtocolsBuffer Buffer
  | ALPNProtocolsUint8Array Uint8Array
  | ALPNProtocolsStringArray (Array String)
  | ALPNProtocolsBufferArray (Array Buffer)
  | ALPNProtocolsUint8ArrayArray (Array Uint8Array)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
alpnProtocols :: Option SSLOptions ALPNProtocols
alpnProtocols = cmap extract $ opt "ALPNProtocols"
  where
    extract (ALPNProtocolsString s) = toForeign s
    extract (ALPNProtocolsBuffer b) = toForeign b
    extract (ALPNProtocolsUint8Array u) = toForeign u
    extract (ALPNProtocolsStringArray sa) = toForeign sa
    extract (ALPNProtocolsBufferArray ba) = toForeign ba
    extract (ALPNProtocolsUint8ArrayArray ua) = toForeign ua

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
sessionTimeout :: Option SSLOptions Int
sessionTimeout = opt "sessionTimeout"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)
ticketKeys :: Option SSLOptions Buffer
ticketKeys = opt "ticketKeys"

-- | The PFX option can take either a String or a Buffer
data PFX = PFXString String | PFXBuffer Buffer

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
pfx :: Option SSLOptions PFX
pfx = cmap extract $ opt "pfx"
  where
    extract (PFXString s) = toForeign s
    extract (PFXBuffer b) = toForeign b

-- | The key option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data Key
  = KeyString String
  | KeyBuffer Buffer
  | KeyStringArray (Array String)
  | KeyBufferArray (Array Buffer)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
key :: Option SSLOptions Key
key = cmap extract $ opt "key"
  where
    extract (KeyString s) = toForeign s
    extract (KeyBuffer b) = toForeign b
    extract (KeyStringArray sa) = toForeign sa
    extract (KeyBufferArray ba) = toForeign ba

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
passphrase :: Option SSLOptions String
passphrase = opt "passphrase"

-- | The cert option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data Cert
  = CertString String
  | CertBuffer Buffer
  | CertStringArray (Array String)
  | CertBufferArray (Array Buffer)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
cert :: Option SSLOptions Cert
cert = cmap extract $ opt "cert"
  where
    extract (CertString s) = toForeign s
    extract (CertBuffer b) = toForeign b
    extract (CertStringArray sa) = toForeign sa
    extract (CertBufferArray ba) = toForeign ba

-- | The CA option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data CA
  = CAString String
  | CABuffer Buffer
  | CAStringArray (Array String)
  | CABufferArray (Array Buffer)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
ca :: Option SSLOptions CA
ca = cmap extract $ opt "ca"
  where
    extract (CAString s) = toForeign s
    extract (CABuffer b) = toForeign b
    extract (CAStringArray sa) = toForeign sa
    extract (CABufferArray ba) = toForeign ba

-- | The CRL option can be a String, a Buffer, an array of strings, or an array
-- | of buffers.
data CRL
  = CRLString String
  | CRLBuffer Buffer
  | CRLStringArray (Array String)
  | CRLBufferArray (Array Buffer)

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
crl :: Option SSLOptions CRL
crl = cmap extract $ opt "crl"
  where
    extract (CRLString s) = toForeign s
    extract (CRLBuffer b) = toForeign b
    extract (CRLStringArray sa) = toForeign sa
    extract (CRLBufferArray ba) = toForeign ba

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
data DHParam = DHParamString String | DHParamBuffer Buffer

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
dhparam :: Option SSLOptions DHParam
dhparam = cmap extract $ opt "dhparam"
  where
    extract (DHParamString s) = toForeign s
    extract (DHParamBuffer b) = toForeign b

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureProtocol :: Option SSLOptions String
secureProtocol = opt "secureProtocol"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
secureOptions :: Option SSLOptions Int
secureOptions = opt "secureOptions"

-- | See the [node docs](https://nodejs.org/api/tls.html#tls_tls_createsecurecontext_options)
sessionIdContext :: Option SSLOptions String
sessionIdContext = opt "sessionIdContext"

-- | Create an HTTPS server, given the SSL options and a function to be executed
-- | when a request is received.
foreign import createServerImpl ::
  forall eff.
  Foreign ->
  (Request -> Response -> Eff (http :: HTTP | eff) Unit) ->
  Eff (http :: HTTP | eff) Server

-- | Create an HTTPS server, given the SSL options and a function to be executed
-- | when a request is received.
createServer :: forall eff.
                Options SSLOptions ->
                (Request -> Response -> Eff (http :: HTTP | eff) Unit) ->
                Eff (http :: HTTP | eff) Server
createServer = createServerImpl <<< options
