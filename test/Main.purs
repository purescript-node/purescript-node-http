module Test.Main where

import Prelude (Unit, unit, pure, bind, void, (<>), ($))

import Data.Foldable (foldMap)

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)

import Node.HTTP (HTTP, listen, createServer, setHeader, requestMethod, 
                  requestURL, responseAsStream, requestAsStream, 
                  setStatusCode)
import Node.HTTP.Client as Client
import Node.Stream
import Node.Encoding (Encoding(..))

foreign import stdout :: forall eff r. Writable r eff

main::forall e. (Partial) => Eff (console::CONSOLE, http::HTTP|e) Unit
main = do
  testBasic
  testHttps

testBasic::forall e. (Partial) => Eff (http::HTTP, console::CONSOLE|e) Unit
testBasic = do
  server <- createServer respond
  listen server 8080 $ void do
    log "Listening on port 8080."
    simpleReq "http://localhost:8080"
  where
  respond req res = do
    setStatusCode res 200
    let inputStream  = requestAsStream req
        outputStream = responseAsStream res
    log (requestMethod req <> " " <> requestURL req)
    case requestMethod req of
      "GET" -> do
        let html = foldMap ((<>) "\n")
              [ "<form method='POST' action='/'>"
              , "  <input name='text' type='text'>"
              , "  <input type='submit'>"
              , "</form>"
              ]
        setHeader res "Content-Type" "text/html"
        writeString outputStream UTF8 html(pure unit)
        end outputStream (pure unit)
      "POST" -> void $ pipe inputStream outputStream

testHttps::forall e. Eff (console::CONSOLE, http::HTTP|e) Unit
testHttps =
  simpleReq "https://api.github.com"

simpleReq::forall e. String -> Eff (console::CONSOLE, http::HTTP|e) Unit
simpleReq uri = do
  log ("GET " <> uri <> ":")
  req <- Client.requestFromURI uri \response -> void do
    log "Response:"
    let responseStream = Client.responseAsStream response
    pipe responseStream stdout
  end (Client.requestAsStream req) (pure unit)
