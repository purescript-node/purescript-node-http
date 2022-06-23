module Test.HTTP2 where

import Prelude

import Control.Monad.ST.Class (liftST)
import Control.Monad.ST.Ref as ST.Ref
import Data.Either (Either(..))
import Data.Foldable (for_)
import Data.Maybe (Maybe(..), fromMaybe)
import Effect (Effect)
import Effect.Console as Console
import Effect.Exception (Error, throwException)
import Node.Encoding as Node.Encoding
import Node.HTTP2 (headerKeys, headerString, sensitiveHeaders, toHeaders, toOptions)
import Node.HTTP2.Client as HTTP2.Client
import Node.HTTP2.Server as HTTP2.Server
import Node.Stream as Node.Stream
import Node.URL as URL
import Test.MockCert (cert, key)
import Unsafe.Coerce (unsafeCoerce)

basic_serverSecure :: (Either Error Unit -> Effect Unit) -> Effect Unit
basic_serverSecure complete = do

  server <- HTTP2.Server.createSecureServer
    (toOptions { key: key, cert: cert })

  void $ HTTP2.Server.onceStreamSecure server \stream _ _ -> do
    HTTP2.Server.respond stream
      ( toHeaders
          { "content-type": "text/html; charset=utf-8"
          , ":status": 200
          }
      )
      (toOptions {})
    void
      $ Node.Stream.writeString (HTTP2.Server.toDuplex stream)
          Node.Encoding.UTF8
          "HTTP/2 Secure Body"
      $ case _ of
          Just err -> throwException err
          Nothing ->
            Node.Stream.end (HTTP2.Server.toDuplex stream)
              $ case _ of
                  Just err -> throwException err
                  Nothing -> do
                    HTTP2.Server.closeServerSecure server (pure unit)
                    complete (Right unit)

  HTTP2.Server.listenSecure server
    (toOptions { port: 8443 })
    (pure unit)

basic_client :: Effect Unit
basic_client = do

  clientsession <- HTTP2.Client.connect
    (URL.parse "https://localhost:8443")
    (toOptions { ca: cert })
    (\_ _ -> pure unit)

  clientstream <- HTTP2.Client.request clientsession
    (toHeaders { ":path": "/" })
    (toOptions {})

  void $ HTTP2.Client.onceResponse clientstream
    \headers _ ->
      for_ (headerKeys headers) \name ->
        Console.log $
          name <> ": " <> fromMaybe "" (headerString headers name)

  let req = HTTP2.Client.toDuplex clientstream

  dataRef <- liftST $ ST.Ref.new ""
  Node.Stream.onDataString req Node.Encoding.UTF8
    \chunk -> void $ liftST $ ST.Ref.modify (_ <> chunk) dataRef
  Node.Stream.onEnd req do
    dataString <- liftST $ ST.Ref.read dataRef
    Console.log $ "\n" <> dataString
    HTTP2.Client.closeSession clientsession (pure unit)

headers_sensitive :: Effect Unit
headers_sensitive = do
  Console.log $ unsafeCoerce $
    toHeaders
      { ":status": "200"
      , "content-type": "text-plain"
      , "ABC": [ "has", "more", "than", "one", "value" ]
      }
      <>
        sensitiveHeaders
          { "cookie": "some-cookie"
          , "other-sensitive-header": "very secret data"
          }
