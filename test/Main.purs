module Test.Main where

import Prelude

import Data.Foldable (foldMap)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Console (log, logShow)
import Effect.Uncurried (EffectFn2)
import Foreign.Object (lookup)
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.EventEmitter (once_)
import Node.HTTP as HTTP
import Node.HTTP.ClientRequest as Client
import Node.HTTP.IncomingMessage as IM
import Node.HTTP.OutgoingMessage as OM
import Node.HTTP.Server (closeAllConnections)
import Node.HTTP.Server as Server
import Node.HTTP.ServerResponse as ServerResponse
import Node.HTTP.Types (HttpServer', IMServer, IncomingMessage, ServerResponse)
import Node.HTTPS as HTTPS
import Node.Net.Server (listenTcp)
import Node.Net.Server as NetServer
import Node.Stream (Duplex, Writable, end, pipe)
import Node.Stream as Stream
import Partial.Unsafe (unsafeCrashWith)
import Unsafe.Coerce (unsafeCoerce)

foreign import setTimeoutImpl :: EffectFn2 Int (Effect Unit) Unit

foreign import stdout :: forall r. Writable r

main :: Effect Unit
main = do
  testBasic
  -- testUpgrade
  testHttpsServer
  testHttps
  testCookies

killServer :: forall transmissionType. HttpServer' transmissionType -> Effect Unit
killServer s = do
  let ns = Server.toNetServer s
  closeAllConnections s
  NetServer.close ns

respond :: Effect Unit -> IncomingMessage IMServer -> ServerResponse -> Effect Unit
respond closeServer req res = do
  ServerResponse.setStatusCode 200 res
  let
    inputStream = IM.toReadable req
    om = ServerResponse.toOutgoingMessage res
    outputStream = OM.toWriteable om

  log (IM.method req <> " " <> IM.url req)
  case IM.method req of
    "GET" -> do
      let
        html = foldMap (_ <> "\n")
          [ "<form method='POST' action='/'>"
          , "  <input name='text' type='text'>"
          , "  <input type='submit'>"
          , "</form>"
          ]

      OM.setHeader "Content-Type" "text/html" om
      void $ Stream.writeString outputStream UTF8 html
      Stream.end outputStream
    "POST" ->
      pipe inputStream outputStream
    _ ->
      unsafeCrashWith "Unexpected HTTP method"
  closeServer

testBasic :: Effect Unit
testBasic = do
  server <- HTTP.createServer
  server # once_ Server.requestH (respond (killServer server))
  let netServer = Server.toNetServer server
  netServer # once_ NetServer.listeningH do
    log "Listening on port 8080."
    let uri = "http://localhost:8080"
    log ("GET " <> uri <> ":")
    req <- HTTP.get uri
    req # once_ Client.responseH logResponse
    end (OM.toWriteable $ Client.toOutgoingMessage req)
  listenTcp netServer { host: "localhost", port: 8080 }

mockCert :: String
mockCert =
  """-----BEGIN CERTIFICATE-----
MIIDWDCCAkCgAwIBAgIJAKm4yWuzx7UpMA0GCSqGSIb3DQEBCwUAMEExCzAJBgNV
BAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMR0wGwYDVQQKDBRwdXJlc2NyaXB0
LW5vZGUtaHR0cDAeFw0xNzA3MjMwMTM4MThaFw0xNzA4MjIwMTM4MThaMEExCzAJ
BgNVBAYTAlVTMRMwEQYDVQQIDApDYWxpZm9ybmlhMR0wGwYDVQQKDBRwdXJlc2Ny
aXB0LW5vZGUtaHR0cDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMrI
7YGwOVZJGemgeGm8e6MTydSQozxlHYwshHDb83pB2LUhkguSRHoUe9CO+uDGemKP
BHMHFCS1Nuhgal3mnCPNbY/57mA8LDIpjJ/j9UD85Aw5c89yEd8MuLoM1T0q/APa
LOmKMgzvfpA0S1/6Hr5Ef/tGdE1gFluVirhgUqvbIBJzqTraQq89jwf+4YmzjCO7
/6FIY0pn4xgcSGyd3i2r/DGbL42QlNmq2MarxxdFJo1llK6YIBhS/fAJCp6hsAnX
+m4hClvJ17Rt+46q4C7KCP6J1U5jFIMtDF7jw6uBr/macenF/ApAHUW0dAiBP9qG
fI2l64syxNSUS3of9p0CAwEAAaNTMFEwHQYDVR0OBBYEFPlsFrLCVM6zgXzKMkDN
lzkLLoCfMB8GA1UdIwQYMBaAFPlsFrLCVM6zgXzKMkDNlzkLLoCfMA8GA1UdEwEB
/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAKvNsmnuO65CUnU1U85UlXYSpyA2
f1SVCwKsRB9omFCbtJv8nZOrFSfooxdNJ0LiS7t4cs6v1+441+Sg4aLA14qy4ezv
Fmjt/0qfS3GNjJRr9KU9ZdZ3oxu7qf2ILUneSJOuU/OjP42rZUV6ruyauZB79PvB
25ENUhpA9z90REYjHuZzUeI60/aRwqQgCCwu5XYeIIxkD+WBPh2lxCfASwQ6/1Iq
fEkZtgzKvcprF8csbb2RNu2AVF2jdxChtl/FCUlSSX13VCROf6dOYJPid9s/wKpE
nN+b2NNE8OJeuskvEckzDe/hbkVptUNi4q2G8tBoKjPPTjdiLjtxuNz7OT0=
-----END CERTIFICATE-----"""

mockKey :: String
mockKey =
  """-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDKyO2BsDlWSRnp
oHhpvHujE8nUkKM8ZR2MLIRw2/N6Qdi1IZILkkR6FHvQjvrgxnpijwRzBxQktTbo
YGpd5pwjzW2P+e5gPCwyKYyf4/VA/OQMOXPPchHfDLi6DNU9KvwD2izpijIM736Q
NEtf+h6+RH/7RnRNYBZblYq4YFKr2yASc6k62kKvPY8H/uGJs4wju/+hSGNKZ+MY
HEhsnd4tq/wxmy+NkJTZqtjGq8cXRSaNZZSumCAYUv3wCQqeobAJ1/puIQpbyde0
bfuOquAuygj+idVOYxSDLQxe48Orga/5mnHpxfwKQB1FtHQIgT/ahnyNpeuLMsTU
lEt6H/adAgMBAAECggEBALSe/54SXx/SAPitbFOSBPYefBmPszXqQsVGKbl00IvG
9sVvX2xbHg83C4masS9g2kXLaYUjevevSXb12ghFjjH9mmcxkPe64QrVI2KPYzY9
isqwqczOp8hqxmdBYvYWwV6VCIgEBcyrzamYSsL0QEntLamc+Z6pxYBR1LuhYEGd
Vq0A+YL/4CZi320+pt05u/635Daon33JqhvDa0QK5xvFYKEcB+IY5eqByOx7nJl8
A55oVagBVjpi//rwoge5aCfbcdyHUmBFYkuCI6SJhvwDmfSHWDkyWWsZAJY5sosN
a824N7XX5ZiBYir+E4ldC6ZlFOnQK5f6Fr0MJeM8uikCgYEA+HAgYgKBpezCrJ0B
I/inIfynaW8k3SCSQhYvqPK591cBKXwghCG2vpUwqIVO/ROP070L9/EtNrFs5fPv
xHQA8P3Weeail6gl9UR5oKNU3bcbIFunUtWi1ua86g/aaofub/hBq2xR+HSnV91W
Ycwewyfc/0j94kDOAFgSGOz0BscCgYEA0PUQXtuu05YTmz2TDtknCcQOVm/UnEg6
1FsKPzmoxWsAMtHXf3FbD3vHql1JfPTJPNcxEEL6fhA1l7ntailHltx8dt9bXmYJ
ANM0n8uSKde5MoFbMhmyYTcRxJW9EC2ivqLotd5iL1mbfvdF02cWmr/5KNxUO1Hk
7TkJturwo3sCgYBc/gNxDEUhKX05BU/O+hz9QMgdVAf1aWK1r/5I/AoWBhAeSiMV
slToA4oCGlwVqMPWWtXnCfSFm2YKsQNXgqBzlGA6otTLdZo3s1jfgyOaFhbmRshb
3jGkxRuDdUmpRJZAfSl/k/0exfN5lRTnaHM/U2WKfPTjQqSZRl4HzHIPMwKBgFVE
W0zKClou+Is1oifB9wsmJM+izLiFRPRYviK0raj5k9gpBu3rXMRBt2VOsek6nk+k
ZFIFcuA0Txo99aKHe74U9PkxBcDMlEnw5Z17XYaTj/ALFyKnl8HRzf9RNxg99xYh
tiJYv+ogf7JcxvKQM4osYkkJN5oJPgiLaOpqjo23AoGBAN3g5kvsYj3OKGh89pGk
osLeL+NNUBDvFsrvFzPMwPGDup6AB1qX1pc4RfyQGzDJqUSTpioWI5v1O6Pmoiak
FO0u08Tb/091Bir5kgglUSi7VnFD3v8ffeKpkkJvtYUj7S9yoH9NQPVhKVCq6mna
TbGfXbnVfNmqgQh71+k02p6S
-----END PRIVATE KEY-----"""

testHttpsServer :: Effect Unit
testHttpsServer = do
  mockKey' <- Buffer.fromString mockKey UTF8
  mockCert' <- Buffer.fromString mockCert UTF8
  server <- HTTPS.createSecureServer'
    { key: [ mockKey' ]
    , cert: [ mockCert' ]
    }
  server # once_ Server.requestH (respond (killServer server))
  let netServer = Server.toNetServer server
  netServer # once_ NetServer.listeningH do
    log "Listening on port 8081."
    let
      optsR =
        { protocol: "https:"
        , method: "GET"
        , hostname: "localhost"
        , port: 8081
        , path: "/"
        , rejectUnauthorized: false
        }
    log $ optsR.method <> " " <> optsR.protocol <> "//" <> optsR.hostname <> ":" <> show optsR.port <> optsR.path <> ":"
    req <- HTTPS.requestOpts optsR
    req # once_ Client.responseH logResponse
    end (OM.toWriteable $ Client.toOutgoingMessage req)
  listenTcp netServer { host: "localhost", port: 8081 }

testHttps :: Effect Unit
testHttps = do
  let uri = "https://pursuit.purescript.org/packages/purescript-node-http/badge"
  log ("GET " <> uri <> ":")
  req <- HTTPS.get uri
  req # once_ Client.responseH logResponse
  end (OM.toWriteable $ Client.toOutgoingMessage req)

testCookies :: Effect Unit
testCookies = do
  let uri = "https://httpbin.org/cookies/set?cookie1=firstcookie&cookie2=secondcookie"
  log ("GET " <> uri <> ":")
  req <- HTTPS.get uri
  req # once_ Client.responseH logResponse
  end (OM.toWriteable $ Client.toOutgoingMessage req)

logResponse :: forall imTy. IncomingMessage imTy -> Effect Unit
logResponse response = void do
  log "Headers:"
  logShow $ IM.headers response
  log "Cookies:"
  logShow $ IM.cookies response
  log "Response:"
  pipe (IM.toReadable response) stdout

testUpgrade :: Effect Unit
testUpgrade = do
  server <- HTTP.createServer
  server # once_ Server.upgradeH handleUpgrade

  server # once_ Server.requestH (respond (mempty))
  let netServer = Server.toNetServer server
  netServer # once_ NetServer.listeningH do
    log $ "Listening on port " <> show httpPort <> "."
    sendRequests
  listenTcp netServer { host: "localhost", port: httpPort }
  where
  httpPort = 3000

  handleUpgrade :: IncomingMessage IMServer -> Duplex -> Buffer -> Effect Unit
  handleUpgrade req socket _ = do
    let upgradeHeader = fromMaybe "" $ lookup "upgrade" $ IM.headers req
    if upgradeHeader == "websocket" then
      void $ Stream.writeString socket UTF8
        "HTTP/1.1 101 Switching Protocols\r\nContent-Length: 0\r\n\r\n"
    else
      void $ Stream.writeString socket UTF8
        "HTTP/1.1 426 Upgrade Required\r\nContent-Length: 0\r\n\r\n"

  sendRequests :: Effect Unit
  sendRequests = do
    -- This tests that the upgrade callback is not called when the request is not an HTTP upgrade
    reqSimple <- HTTP.requestOpts { port: httpPort }
    reqSimple # once_ Client.responseH \response -> do
      if (IM.statusCode response /= 200) then
        unsafeCrashWith "Unexpected response to simple request on `testUpgrade`"
      else
        pure unit
    end (OM.toWriteable $ Client.toOutgoingMessage reqSimple)

    {-
      These two requests test that the upgrade callback is called and that it has
      access to the original request and can write to the underlying TCP socket
    -}
    reqUpgrade <- HTTP.requestOpts
      { port: httpPort
      , headers: unsafeCoerce
          { "Connection": "upgrade"
          , "Upgrade": "something"
          }
      }
    reqUpgrade # once_ Client.responseH \response -> do
      if (IM.statusCode response /= 426) then
        unsafeCrashWith "Unexpected response to upgrade request on `testUpgrade`"
      else
        pure unit
    end (OM.toWriteable $ Client.toOutgoingMessage reqUpgrade)

    reqWSUpgrade <- HTTP.requestOpts
      { port: httpPort
      , headers: unsafeCoerce
          { "Connection": "upgrade"
          , "Upgrade": "websocket"
          }
      }
    reqWSUpgrade # once_ Client.responseH \response -> do
      if (IM.statusCode response /= 101) then
        unsafeCrashWith "Unexpected response to websocket upgrade request on `testUpgrade`"
      else
        pure unit
    end (OM.toWriteable $ Client.toOutgoingMessage reqWSUpgrade)
