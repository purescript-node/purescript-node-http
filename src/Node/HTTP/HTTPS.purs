-- | This module defines low-level bindings to the Node HTTPS module.

module Node.HTTP.HTTPS
  ( createServer

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
  ) where

import Prelude

import Control.Monad.Eff (Eff)
import Data.Options (Options, Option, options, opt)
import Data.Foreign (Foreign)
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
