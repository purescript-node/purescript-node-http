-- | This module defines low-level bindings to the Node HTTP module.

module Node.HTTP
  ( Server
  , Request
  , Response

  , createServer
  , listen
  , close
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

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Effect (Effect)
import Foreign.Object (Object)
import Node.Stream (Writable, Readable)
import Unsafe.Coerce (unsafeCoerce)

-- | The type of a HTTP server object
foreign import data Server :: Type

-- | A HTTP request object
foreign import data Request :: Type

-- | A HTTP response object
foreign import data Response :: Type

-- | Create a HTTP server, given a function to be executed when a request is received.
foreign import createServer :: (Request -> Response -> Effect Unit) -> Effect Server

foreign import listenImpl :: Server -> Int -> String -> Nullable Int -> Effect Unit -> Effect Unit

foreign import closeImpl :: Server -> Effect Unit -> Effect Unit

-- | Listen on a port in order to start accepting HTTP requests. The specified callback will be run when setup is complete.
listen :: Server -> ListenOptions -> Effect Unit -> Effect Unit
listen server opts done = listenImpl server opts.port opts.hostname (toNullable opts.backlog) done

-- | Close a listening HTTP server. The specified callback will be run the server closing is complete.
close :: Server -> Effect Unit -> Effect Unit
close server done = closeImpl server done

-- | Options to be supplied to `listen`. See the [Node API](https://nodejs.org/dist/latest-v6.x/docs/api/http.html#http_server_listen_handle_callback) for detailed information about these.
type ListenOptions =
  { hostname :: String
  , port :: Int
  , backlog :: Maybe Int
  }

-- | Listen on a unix socket. The specified callback will be run when setup is complete.
foreign import listenSocket :: Server -> String -> Effect Unit -> Effect Unit

-- | Get the request HTTP version
httpVersion :: Request -> String
httpVersion = _.httpVersion <<< unsafeCoerce

-- | Get the request headers as a hash
requestHeaders :: Request -> Object String
requestHeaders = _.headers <<< unsafeCoerce

-- | Get the request method (GET, POST, etc.)
requestMethod :: Request -> String
requestMethod = _.method <<< unsafeCoerce

-- | Get the request URL
requestURL :: Request -> String
requestURL = _.url <<< unsafeCoerce

-- | Coerce the request object into a readable stream.
requestAsStream :: Request -> Readable ()
requestAsStream = unsafeCoerce

-- | Set a header with a single value.
foreign import setHeader :: Response -> String -> String -> Effect Unit

-- | Set a header with multiple values.
foreign import setHeaders :: Response -> String -> Array String -> Effect Unit

-- | Set the status code.
foreign import setStatusCode :: Response -> Int -> Effect Unit

-- | Set the status message.
foreign import setStatusMessage :: Response -> String -> Effect Unit

-- | Coerce the response object into a writable stream.
responseAsStream :: Response -> Writable ()
responseAsStream = unsafeCoerce
