-- | This module defines low-level bindings to the Node HTTP client.

module Node.HTTP.Client
  ( Request()
  , Response()
  , RequestHeaders(..)
  , RequestOptions()
  , RequestFamily(..)
  , protocol
  , hostname
  , port
  , method
  , path
  , headers
  , auth
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

import Prelude (Unit, (<<<), ($))

import Control.Monad.Eff (Eff)
import Data.Maybe (Maybe)
import Data.Foreign (Foreign, toForeign)
import Data.Options (Options, Option, options, opt)
import Data.StrMap (StrMap(), delete, lookup)
import Data.Functor.Contravariant ((>$<))
import Node.HTTP (HTTP())
import Node.Stream (Readable, Writable)
import Node.URL as URL
import Unsafe.Coerce (unsafeCoerce)

-- | A HTTP request object
foreign import data Request :: *

-- | A HTTP response object
foreign import data Response :: *

-- | A HTTP request object
newtype RequestHeaders = RequestHeaders (StrMap String)

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

-- | IP address family to use when resolving `hostname`.
-- | Valid values are `IPV6` and `IPV4`
family :: Option RequestOptions RequestFamily
family = familyToOption >$< opt "family"

-- | Translates RequestFamily values to Int parameters for Request
familyToOption :: RequestFamily -> Int
familyToOption IPV4 = 4
familyToOption IPV6 = 6

-- | Make a HTTP request using the specified options and response callback.
foreign import requestImpl :: forall eff. Foreign -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request

-- | Make a HTTP request using the specified options and response callback.
request :: forall eff. Options RequestOptions -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request
request = requestImpl <<< options

-- | Make a HTTP request from a URI string and response callback.
requestFromURI :: forall eff. String -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request
requestFromURI = requestImpl <<< toForeign <<< URL.parse

-- | Create a writable stream from a request object.
requestAsStream :: forall eff r. Request -> Writable r (http :: HTTP | eff)
requestAsStream = unsafeCoerce

-- | Create a readable stream from a response object.
responseAsStream :: forall eff w. Response -> Readable w (http :: HTTP | eff)
responseAsStream = unsafeCoerce

-- | Set the socket timeout for a `Request`
foreign import setTimeout :: forall eff. Request -> Int -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit

-- | Get the request HTTP version
httpVersion :: Response -> String
httpVersion = _.httpVersion <<< unsafeCoerce

headers' :: forall a. Response -> StrMap a
headers' = _.headers <<< unsafeCoerce

-- | Get the response headers as a hash
-- | Cookies are not included and could be retrieved with responseCookies
responseHeaders :: Response -> StrMap String
responseHeaders res = delete "set-cookie" $ headers' res

-- | Get the response cookies as Just (Array String) or Nothing if no cookies
responseCookies :: Response -> Maybe (Array String)
responseCookies res = lookup "set-cookie" $ headers' res

-- | Get the response status code
statusCode :: Response -> Int
statusCode = _.statusCode <<< unsafeCoerce

-- | Get the response status message
statusMessage :: Response -> String
statusMessage = _.statusMessage <<< unsafeCoerce
