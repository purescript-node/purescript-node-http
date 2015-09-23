module Test.Main where

import Prelude

import Control.Monad.Eff.Console

import Node.HTTP
import Node.Stream
import Node.Encoding

main = do
  server <- createServer respond
  listen server 8080 do
    log "Listening on port 8080."
  where
  respond req res = do
    setStatusCode res 200
    let inputStream  = requestAsStream req
        outputStream = responseAsStream res
    log (requestMethod req <> " " <> requestURL req)
    case requestMethod req of
      "GET" -> do
        let html = "<form method='POST' action='/'>"
                <> "  <input name='text' type='text'>"
                <> "  <input type='submit'>"
                <> "</form>"
        setHeader res "Content-Type" "text/html"
        writeString outputStream UTF8 html(return unit)
        end outputStream (return unit)
      "POST" -> void $ pipe inputStream outputStream
