-- | This module defines low-level bindings to the Node HTTP client.

module Node.HTTP.Client
  ( Request()
  , Response()
  , RequestHeaders(..)
  , RequestOptions()
  , protocol
  , hostname
  , port
  , method
  , path
  , headers
  , auth
  , request
  , requestFromURI
  , requestAsStream
  , responseAsStream
  , setTimeout
  , httpVersion
  , responseHeaders
  , statusCode
  , statusMessage
  ) where

import Prelude

import Data.Foreign
import Data.Options
import Data.StrMap (StrMap())

import Node.HTTP (HTTP())
import Node.Stream

import Control.Monad.Eff

import Unsafe.Coerce (unsafeCoerce)

-- | A HTTP request object
foreign import data Request :: *

-- | A HTTP response object
foreign import data Response :: *

-- | A HTTP request object
newtype RequestHeaders = RequestHeaders (StrMap String)

instance requestHeadersIsOption :: IsOption RequestHeaders where
  assoc k v = assoc (optionFn k) (unsafeCoerce v :: {})

-- | The type of HTTP request options
data RequestOptions

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

-- | Make a HTTP request using the specified options and response callback.
foreign import requestImpl :: forall eff. Foreign -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request

-- | Make a HTTP request using the specified options and response callback.
request :: forall eff. Options RequestOptions -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request
request = requestImpl <<< options

-- | Make a HTTP request from a URI string and response callback.
requestFromURI :: forall eff. String -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request
requestFromURI = requestImpl <<< toForeign

-- | Create a writable stream from a request object.
requestAsStream :: forall eff r a. Request -> Writable r (http :: HTTP | eff) a
requestAsStream = unsafeCoerce

-- | Create a readable stream from a response object.
responseAsStream :: forall eff w a. Response -> Readable w (http :: HTTP | eff) a
responseAsStream = unsafeCoerce

-- | Set the socket timeout for a `Request`
foreign import setTimeout :: forall eff. Request -> Int -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit

-- | Get the request HTTP version
httpVersion :: Response -> String
httpVersion = _.httpVersion <<< unsafeCoerce

-- | Get the response headers as a hash
responseHeaders :: Response -> StrMap String
responseHeaders = _.headers <<< unsafeCoerce

-- | Get the response status code
statusCode :: Response -> Int
statusCode = _.statusCode <<< unsafeCoerce

-- | Get the response status message
statusMessage :: Response -> String
statusMessage = _.statusMessage <<< unsafeCoerce
