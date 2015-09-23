-- | This module defines low-level bindings to the Node HTTP module.

module Node.HTTP where

import Prelude

import Data.StrMap
import Control.Monad.Eff
import Node.Stream
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

-- | Listen on the specified port. The specified callback will be run when setup is complete.
foreign import listen :: forall eff. Server -> Int -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit

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
requestAsStream :: forall eff a. Request -> Readable () (http :: HTTP | eff) a
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
responseAsStream :: forall eff a. Response -> Writable () (http :: HTTP | eff) a
responseAsStream = unsafeCoerce
