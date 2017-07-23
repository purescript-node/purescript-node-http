module Test.Main where

import Prelude

import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log, logShow)

import Data.Foldable (foldMap)
import Data.Maybe (Maybe(..))
import Data.Options (Options, (:=))

import Node.Encoding (Encoding(..))
import Node.HTTP (HTTP, Request, Response, listen, createServer, createServerS, key, cert, setHeader, requestMethod, requestURL, responseAsStream, requestAsStream, setStatusCode)
import Node.HTTP.Client as Client
import Node.Stream (Writable, end, pipe, writeString)

import Partial.Unsafe (unsafeCrashWith)
import Unsafe.Coerce (unsafeCoerce)

foreign import stdout :: forall eff r. Writable r eff

main :: forall eff. Eff (console :: CONSOLE, http :: HTTP | eff) Unit
main = do
  testBasic
  testHttpsServer
  testHttps
  testCookies

respond :: forall eff. Request -> Response -> Eff (console :: CONSOLE, http :: HTTP | eff) Unit
respond req res = do
  setStatusCode res 200
  let inputStream  = requestAsStream req
      outputStream = responseAsStream res
  log (requestMethod req <> " " <> requestURL req)
  case requestMethod req of
    "GET" -> do
      let html = foldMap (_ <> "\n")
            [ "<form method='POST' action='/'>"
            , "  <input name='text' type='text'>"
            , "  <input type='submit'>"
            , "</form>"
            ]
      setHeader res "Content-Type" "text/html"
      _ <- writeString outputStream UTF8 html (pure unit)
      end outputStream (pure unit)
    "POST" -> void $ pipe inputStream outputStream
    _ -> unsafeCrashWith "Unexpected HTTP method"

testBasic :: forall eff. Eff (console :: CONSOLE, http :: HTTP | eff) Unit
testBasic = do
  server <- createServer respond
  listen server { hostname: "localhost", port: 8080, backlog: Nothing } $ void do
    log "Listening on port 8080."
    simpleReq "http://localhost:8080"

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

testHttpsServer :: forall eff. Eff (console :: CONSOLE, http :: HTTP | eff) Unit
testHttpsServer = do
  server <- createServerS (key := mockKey <> cert := mockCert) respond
  listen server { hostname: "localhost", port: 8081, backlog: Nothing } $ void do
    log "Listening on port 8081."
    complexReq $
      Client.protocol := "https:" <>
      Client.method := "GET" <>
      Client.hostname := "localhost" <>
      Client.port := 8081 <>
      Client.path := "/" <>
      Client.rejectUnauthorized := false

testHttps :: forall eff. Eff (console :: CONSOLE, http :: HTTP | eff) Unit
testHttps =
  simpleReq "https://pursuit.purescript.org/packages/purescript-node-http/badge"

testCookies :: forall eff. Eff (console :: CONSOLE, http :: HTTP | eff) Unit
testCookies =
  simpleReq
    "https://httpbin.org/cookies/set?cookie1=firstcookie&cookie2=secondcookie"

simpleReq :: forall eff. String -> Eff (console :: CONSOLE, http :: HTTP | eff) Unit
simpleReq uri = do
  log ("GET " <> uri <> ":")
  req <- Client.requestFromURI uri logResponse
  end (Client.requestAsStream req) (pure unit)

complexReq :: forall eff. Options Client.RequestOptions -> Eff (console :: CONSOLE, http :: HTTP | eff) Unit
complexReq options = do
  log $ opts.method <> " " <> opts.hostname <> opts.path <> ":"
  req <- Client.request options logResponse
  end (Client.requestAsStream req) (pure unit)
  where
    opts = unsafeCoerce options

logResponse :: forall eff. Client.Response -> Eff (console :: CONSOLE, http :: HTTP | eff) Unit
logResponse response = void do
  log "Headers:"
  logShow $ Client.responseHeaders response
  log "Cookies:"
  logShow $ Client.responseCookies response
  log "Response:"
  let responseStream = Client.responseAsStream response
  pipe responseStream stdout
