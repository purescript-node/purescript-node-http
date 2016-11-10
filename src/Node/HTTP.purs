-- | This module defines low-level bindings to the Node HTTP module.

module Node.HTTP
  ( Server
  , Request
  , Response
  , HTTP

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

import Control.Monad.Eff (Eff)

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Data.StrMap (StrMap)

import Node.Stream (Writable, Readable)

import Unsafe.Coerce (unsafeCoerce)

-- | The type of a HTTP server object
foreign import data Server :: *

-- | A HTTP request object
foreign import data Request :: *

-- | A HTTP response object
foreign import data Response :: *

-- | The effect associated with using the HTTP module.
foreign import data HTTP :: !

-- | Create a HTTP server, given a function to be executed when a request is received.
foreign import createServer :: forall eff. (Request -> Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Server

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
