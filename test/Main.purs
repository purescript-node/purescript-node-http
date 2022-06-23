module Test.Main where

import Prelude

import Control.Parallel (parSequence_)
import Data.Either (Either(..))
import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Options (Options, options, (:=))
import Data.Tuple (Tuple(..))
import Effect (Effect)
import Effect.Aff (Milliseconds(..), launchAff_, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Console (log, logShow)
import Effect.Exception (Error)
import Foreign.Object (fromFoldable, lookup)
import Node.Encoding (Encoding(..))
import Node.HTTP (Request, Response, close, createServer, listen, onRequest, onUpgrade, requestAsStream, requestHeaders, requestMethod, requestURL, responseAsStream, setHeader, setStatusCode)
import Node.HTTP.Client as Client
import Node.HTTP.Secure as HTTPS
import Node.Net.Socket as Socket
import Node.Process as Node.Process
import Node.Stream (end, pipe, writeString)
import Partial.Unsafe (unsafeCrashWith, unsafePartial)
import Test.HTTP2 as HTTP2
import Test.HTTP2Aff as HTTP2Aff
import Test.MockCert (cert, key)
import Test.Spec (describe, it)
import Test.Spec.Assertions (expectError, shouldReturn)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (defaultConfig, runSpec')
import Unsafe.Coerce (unsafeCoerce)

main :: Effect Unit
main = unsafePartial $ launchAff_ do
  runSpec' (defaultConfig { timeout = Just (Milliseconds 2000.0) }) [ consoleReporter ] do
    describe "HTTP" do
      it "test basic" do
        flip shouldReturn unit $ makeAff \complete -> do
          testBasic complete
          pure nonCanceler
      it "test upgrade" do
        flip shouldReturn unit $ makeAff \complete -> do
          testUpgrade complete
          pure nonCanceler
      it "test HttpsServer" do
        flip shouldReturn unit $ makeAff \complete -> do
          testHttpsServer complete
          pure nonCanceler
    describe "HTTP/2" do
      it "test basic" do
        flip shouldReturn unit $ makeAff \complete -> do
          HTTP2.basic_serverSecure complete
          HTTP2.basic_client
          pure nonCanceler
      it "headers_sensitive" do
        flip shouldReturn unit $ liftEffect HTTP2.headers_sensitive
    describe "HTTP/2 Aff" do
      it "push1" do
        flip shouldReturn unit $
          parSequence_
            [ HTTP2Aff.push1_serverSecure
            , HTTP2Aff.push1_client
            ]
      it "error1_serverSecure" do
        expectError HTTP2Aff.error1_serverSecure
      it "error2 serverSecure" do
        expectError HTTP2Aff.error2_serverSecure
      it "error1_client" do
        expectError HTTP2Aff.error1_client
      it "error2_client" do
        expectError HTTP2Aff.error2_client
      it "headers" do
        flip shouldReturn unit $
          parSequence_
            [ HTTP2Aff.headers_serverSecure
            , HTTP2Aff.headers_client
            ]
      it "trailers" do
        flip shouldReturn unit $
          parSequence_
            [ HTTP2Aff.trailers_serverSecure
            , HTTP2Aff.trailers_client
            ]
      it "cancel1_secureServer" do
        flip shouldReturn unit do
          HTTP2Aff.cancel1_serverSecure

respond :: Request -> Response -> Effect Unit
respond req res = do
  setStatusCode res 200
  let
    inputStream = requestAsStream req
    outputStream = responseAsStream res
  log (requestMethod req <> " " <> requestURL req)
  case requestMethod req of
    "GET" -> do
      let
        html = foldMap (_ <> "\n")
          [ "<form method='POST' action='/'>"
          , "  <input name='text' type='text'>"
          , "  <input type='submit'>"
          , "</form>"
          ]
      setHeader res "Content-Type" "text/html"
      _ <- writeString outputStream UTF8 html mempty
      end outputStream (const $ pure unit)
    "POST" -> void $ pipe inputStream outputStream
    _ -> unsafeCrashWith "Unexpected HTTP method"

testBasic :: (Either Error Unit -> Effect Unit) -> Effect Unit
testBasic complete = do
  server <- createServer \_ _ -> pure unit
  onRequest server \req res -> do
    respond req res
    close server $ complete (Right unit)
  listen server { hostname: "localhost", port: 8080, backlog: Nothing } $ void do
    log "Listening on port 8080."
  simpleReq "http://localhost:8080"

testHttpsServer :: (Either Error Unit -> Effect Unit) -> Effect Unit
testHttpsServer complete = do
  server <- HTTPS.createServer sslOpts \_ _ -> pure unit
  onRequest server \req res -> do
    respond req res
    close server $ complete (Right unit)
  listen server { hostname: "localhost", port: 8081, backlog: Nothing } $ void do
    log "Listening on port 8081."
    complexReq $
      Client.protocol := "https:"
        <> Client.method := "GET"
        <> Client.hostname := "localhost"
        <> Client.port := 8081
        <> Client.path := "/"
        <>
          Client.rejectUnauthorized := false
  where
  sslOpts =
    HTTPS.key := HTTPS.keyString key <>
      HTTPS.cert := HTTPS.certString cert

testCookies :: (Either Error Unit -> Effect Unit) -> Effect Unit
testCookies _ =
  -- TODO I don't see how this tests cookies
  simpleReq
    "https://httpbin.org/cookies/set?cookie1=firstcookie&cookie2=secondcookie"

simpleReq :: String -> Effect Unit
simpleReq uri = do
  log ("GET " <> uri <> ":")
  req <- Client.requestFromURI uri logResponse
  end (Client.requestAsStream req) (const $ pure unit)

complexReq :: Options Client.RequestOptions -> Effect Unit
complexReq opts = do
  log $ optsR.method <> " " <> optsR.protocol <> "//" <> optsR.hostname <> ":" <> optsR.port <> optsR.path <> ":"
  req <- Client.request opts logResponse
  end (Client.requestAsStream req) (const $ pure unit)
  where
  optsR = unsafeCoerce $ options opts

logResponse :: Client.Response -> Effect Unit
logResponse response = void do
  log "Headers:"
  logShow $ Client.responseHeaders response
  log "Cookies:"
  logShow $ Client.responseCookies response
  log "Response:"
  let responseStream = Client.responseAsStream response
  pipe responseStream Node.Process.stdout

testUpgrade :: (Either Error Unit -> Effect Unit) -> Effect Unit
testUpgrade complete = do
  server <- createServer \_ _ -> pure unit
  onRequest server \req res -> do
    respond req res
  onUpgrade server handleUpgrade
  listen server { hostname: "localhost", port: 3000, backlog: Nothing } do
    log "Listening on port 3000."
  sendRequests (close server $ complete (Right unit))
  where
  handleUpgrade req socket _ = do
    let upgradeHeader = fromMaybe "" $ lookup "upgrade" $ requestHeaders req
    if upgradeHeader == "websocket" then
      void
        $ Socket.writeString
            socket
            "HTTP/1.1 101 Switching Protocols\r\nContent-Length: 0\r\n\r\n"
            UTF8
        $ pure unit
    else
      void
        $ Socket.writeString
            socket
            "HTTP/1.1 426 Upgrade Required\r\nContent-Length: 0\r\n\r\n"
            UTF8
        $ pure unit

  sendRequests complete' = do
    -- This tests that the upgrade callback is not called when the request is not an HTTP upgrade
    reqSimple <- Client.request (Client.port := 3000) \response -> do
      if (Client.statusCode response /= 200) then
        unsafeCrashWith "Unexpected response to simple request on `testUpgrade`"
      else
        pure unit
    end (Client.requestAsStream reqSimple) (const $ pure unit)
    {-
      These two requests test that the upgrade callback is called and that it has
      access to the original request and can write to the underlying TCP socket
    -}
    let
      headers = Client.RequestHeaders $ fromFoldable
        [ Tuple "Connection" "upgrade"
        , Tuple "Upgrade" "something"
        ]
    reqUpgrade <- Client.request
      (Client.port := 3000 <> Client.headers := headers)
      \response -> do
        if (Client.statusCode response /= 426) then
          unsafeCrashWith "Unexpected response to upgrade request on `testUpgrade`"
        else
          pure unit
    end (Client.requestAsStream reqUpgrade) (const $ pure unit)

    let
      wsHeaders = Client.RequestHeaders $ fromFoldable
        [ Tuple "Connection" "upgrade"
        , Tuple "Upgrade" "websocket"
        ]

    reqWSUpgrade <- Client.request
      (Client.port := 3000 <> Client.headers := wsHeaders)
      \response -> do
        if (Client.statusCode response /= 101) then
          unsafeCrashWith "Unexpected response to websocket upgrade request on `testUpgrade`"
        else
          pure unit
    end (Client.requestAsStream reqWSUpgrade) (const $ pure unit)
    complete'
