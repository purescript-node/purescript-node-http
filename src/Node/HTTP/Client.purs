-- | This module defines low-level bindings to the Node HTTP client.

module Node.HTTP.Client
  ( Request
  , Response
  , RequestHeaders(..)
  , RequestOptions
  , RequestFamily(..)
  , protocol
  , hostname
  , port
  , method
  , path
  , headers
  , auth
  , key
  , cert
  , rejectUnauthorized
  , family
  , request
  , requestFromURI
  , requestAsStream
  , responseAsStream
  , setTimeout
  , httpVersion
  , responseHeaders
  , responseCookies
  , statusCode
  , statusMessage
  ) where

import Prelude

import Data.Functor.Contravariant ((>$<))
import Data.Maybe (Maybe)
import Data.Options (Option, Options, opt, options)
import Effect (Effect)
import Foreign (Foreign, unsafeToForeign)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Stream (Readable, Writable)
import Node.URL as URL
import Unsafe.Coerce (unsafeCoerce)

-- | A HTTP request object
foreign import data Request :: Type

-- | A HTTP response object
foreign import data Response :: Type

-- | A HTTP request object
newtype RequestHeaders = RequestHeaders (Object String)

-- | The type of HTTP request options
data RequestOptions

-- | Values for the `family` request option
data RequestFamily = IPV4 | IPV6

-- | The protocol to use
protocol :: Option RequestOptions String
protocol = opt "protocol"

-- | Domain name or IP
hostname :: Option RequestOptions String
hostname = opt "hostname"

-- | Port of remote server
port :: Option RequestOptions Int
port = opt "port"

-- | The HTTP request method: GET, POST, etc.
method :: Option RequestOptions String
method = opt "method"

-- | The request path, including query string if appropriate.
path :: Option RequestOptions String
path = opt "path"

headers :: Option RequestOptions RequestHeaders
headers = opt "headers"

-- | Basic authentication
auth :: Option RequestOptions String
auth = opt "auth"

-- | Private Key
key :: Option RequestOptions String
key = opt "key"

-- | Public x509 certificate
cert :: Option RequestOptions String
cert = opt "cert"

-- | Is cert verified against CAs
rejectUnauthorized :: Option RequestOptions Boolean
rejectUnauthorized = opt "rejectUnauthorized"

-- | IP address family to use when resolving `hostname`.
-- | Valid values are `IPV6` and `IPV4`
family :: Option RequestOptions RequestFamily
family = familyToOption >$< opt "family"

-- | Translates RequestFamily values to Int parameters for Request
familyToOption :: RequestFamily -> Int
familyToOption IPV4 = 4
familyToOption IPV6 = 6

-- | Make a HTTP request using the specified options and response callback.
foreign import requestImpl :: Foreign -> (Response -> Effect Unit) -> Effect Request

-- | Make a HTTP request using the specified options and response callback.
request :: Options RequestOptions -> (Response -> Effect Unit) -> Effect Request
request = requestImpl <<< options

-- | Make a HTTP request from a URI string and response callback.
requestFromURI :: String -> (Response -> Effect Unit) -> Effect Request
requestFromURI = requestImpl <<< unsafeToForeign <<< URL.parse

-- | Create a writable stream from a request object.
requestAsStream :: forall r. Request -> Writable r
requestAsStream = unsafeCoerce

-- | Create a readable stream from a response object.
responseAsStream :: forall w. Response -> Readable w
responseAsStream = unsafeCoerce

-- | Set the socket timeout for a `Request`
foreign import setTimeout :: Request -> Int -> Effect Unit -> Effect Unit

-- | Get the request HTTP version
httpVersion :: Response -> String
httpVersion = _.httpVersion <<< unsafeCoerce

headers' :: forall a. Response -> Object a
headers' = _.headers <<< unsafeCoerce

-- | Get the response headers as a hash
-- | Cookies are not included and could be retrieved with responseCookies
responseHeaders :: Response -> Object String
responseHeaders res = Object.delete "set-cookie" $ headers' res

-- | Get the response cookies as Just (Array String) or Nothing if no cookies
responseCookies :: Response -> Maybe (Array String)
responseCookies res = Object.lookup "set-cookie" $ headers' res

-- | Get the response status code
statusCode :: Response -> Int
statusCode = _.statusCode <<< unsafeCoerce

-- | Get the response status message
statusMessage :: Response -> String
statusMessage = _.statusMessage <<< unsafeCoerce
