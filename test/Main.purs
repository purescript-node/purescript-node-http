module Test.Main where

import Prelude

import Data.Foldable (foldMap)
import Data.Options

import Control.Monad.Eff.Console

import Node.HTTP
import qualified Node.HTTP.Client as Client
import Node.Stream
import Node.Encoding

foreign import stdout :: forall eff r. Writable r eff

main = do
  server <- createServer respond
  listen server 8080 $ void do
    log "Listening on port 8080."
    req <- Client.requestFromURI "http://localhost:8080/" \response -> void do
      log "Response from GET /:"
      let responseStream = Client.responseAsStream response
      pipe responseStream stdout
    end (Client.requestAsStream req) (return unit)
  where
  respond req res = do
    setStatusCode res 200
    let inputStream  = requestAsStream req
        outputStream = responseAsStream res
    log (requestMethod req <> " " <> requestURL req)
    case requestMethod req of
      "GET" -> do
        let html = foldMap (<> "\n")
              [ "<form method='POST' action='/'>"
              , "  <input name='text' type='text'>"
              , "  <input type='submit'>"
              , "</form>"
              ]
        setHeader res "Content-Type" "text/html"
        writeString outputStream UTF8 html(return unit)
        end outputStream (return unit)
      "POST" -> void $ pipe inputStream outputStream
