module Test.HTTP2Aff where

import Prelude

import Control.Alternative ((<|>))
import Control.Parallel (parSequence_)
import Data.Either (either)
import Data.Maybe (fromJust, fromMaybe)
import Data.String as String
import Data.Tuple (fst)
import Effect.Aff (Aff, attempt, catchError, error, forkAff, killFiber, throwError)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Node.HTTP2 (HeadersObject, headerArray, headerKeys, headerString, toHeaders, toOptions)
import Node.HTTP2.Client.Aff as Client.Aff
import Node.HTTP2.Server.Aff as Server.Aff
import Node.Stream.Aff (end, fromStringUTF8, readAll, toStringUTF8, write)
import Node.URL as URL
import Partial.Unsafe (unsafePartial)
import Test.MockCert (cert, key)
import Unsafe.Coerce (unsafeCoerce)

-- | Print anything to the console.
console :: forall a. a -> Aff Unit
console x = liftEffect $ Console.log (unsafeCoerce x)

push1_serverSecure :: Aff Unit
push1_serverSecure = do

  either (\err -> liftEffect $ Console.error (unsafeCoerce err)) pure =<< attempt do
    -- 1. Start the server, wait for a connection.
    server <- Server.Aff.createSecureServer
      (toOptions { key: key, cert: cert })
    void $ Server.Aff.listenSecure server
      (toOptions { port: 8444 })
      \_session _headers stream -> do

        -- 2. Wait to receive a request.
        let s = Server.Aff.toDuplex stream
        requestBody <- toStringUTF8 =<< (fst <$> readAll s)
        console $ "SERVER Request body: " <> requestBody

        -- 3. Send a response stream.
        Server.Aff.respond stream (toOptions {}) (toHeaders {})
        write s =<< fromStringUTF8 "HTTP/2 secure response body Aff"

        -- 4. Push a new stream.
        stream2 <- Server.Aff.pushStream stream (toOptions {}) (toHeaders {})
        Server.Aff.respond stream2 (toOptions {}) (toHeaders {})
        let s2 = Server.Aff.toDuplex stream2
        write s2 =<< fromStringUTF8 "HTTP/2 secure push body Aff"
        end s2

        -- 5. End the response, end the session
        end s
        -- Server.Aff.closeSession session

        -- After one session, stop the server.
        Server.Aff.closeSecureServer server

push1_client :: Aff Unit
push1_client = do

  either (\err -> console err) pure =<< attempt do
    -- 1. Begin the session, open a connection.
    session <- Client.Aff.connect
      (toOptions { ca: cert })
      (URL.parse "https://localhost:8444")

    -- 2. Send a request.
    stream <- Client.Aff.request session
      (toOptions { endStream: false })
      (toHeaders {})

    let s = Client.Aff.toDuplex stream

    write s =<< fromStringUTF8 "HTTP/2 secure request body Aff"
    end s

    -- 3. Wait for the response.
    _ <- Client.Aff.waitResponse stream

    -- We have to do steps 4 and 5 concurrently because we don't know which of
    -- `readAll` or `waitPush` will complete first.
    parSequence_
      [ do
          -- 4. Wait for the reponse body.
          responseBody <- toStringUTF8 =<< (fst <$> readAll s)
          console $ "CLIENT Response body: " <> responseBody
      , do
          -- 5. Receive a pushed stream.
          { streamPushed } <- Client.Aff.waitPush session
          bodyPushed <- toStringUTF8 =<< (fst <$> readAll (Client.Aff.toDuplex streamPushed))
          console $ "CLIENT Pushed body: " <> bodyPushed
      ]

    -- 6. Close the session.
    Client.Aff.closeSession session

headers_serverSecure :: Aff Unit
headers_serverSecure = do

  -- 1. Start the server, wait for a connection.
  server <- Server.Aff.createSecureServer
    (toOptions { key: key, cert: cert })
  Server.Aff.listenSecure server
    (toOptions { port: 8445 })
    \_session headers stream -> do
      console $ "SERVER " <> headersShow headers

      -- 2. Receive a request. Wait for the end of the request.
      _ <- readAll (Server.Aff.toDuplex stream)
      _ <- Server.Aff.waitEnd stream

      -- 3. Send a response.
      Server.Aff.respond stream (toOptions {}) $ toHeaders
        { "normal": "server normal header"
        }
      -- TODO
      -- Error [ERR_HTTP2_HEADERS_AFTER_RESPOND]: Cannot specify additional headers after response initiated
      -- Server.Aff.sendHeadersAdditional stream $ toHeaders
      --   { "additional": "server additional header"
      --   }

      -- 4. Push a new stream.
      stream2 <- Server.Aff.pushStream stream (toOptions {}) (toHeaders {})
      Server.Aff.respond stream2 (toOptions {})
        ( toHeaders
            { "pushnormal": "server normal pushed header"
            }
        )
      end (Server.Aff.toDuplex stream2)

      -- 5. End the response.
      end (Server.Aff.toDuplex stream)

      -- After one session, stop the server.
      Server.Aff.closeSecureServer server

headers_client :: Aff Unit
headers_client = do

  -- 1. Begin the session, open a connection.
  session <- Client.Aff.connect
    (toOptions { ca: cert })
    (URL.parse "https://localhost:8445")

  -- 2. Send a request.
  stream <- Client.Aff.request session (toOptions {}) $ toHeaders
    { "normal": "client normal header"
    }
  end (Client.Aff.toDuplex stream)

  -- 3. Wait for the response.
  headers <- Client.Aff.waitResponse stream
  console $ "CLIENT " <> headersShow headers

  -- 4. Receive a pushed stream.
  { headersRequest, headersResponse } <- Client.Aff.waitPush session
  console $ "CLIENT Pushed Request " <> headersShow headersRequest
  console $ "CLIENT Pushed Response " <> headersShow headersResponse

  -- 5. Wait for the stream to end, then close the connection.
  _ <- Client.Aff.waitEnd stream
  Client.Aff.closeSession session

trailers_serverSecure :: Aff Unit
trailers_serverSecure = do

  -- 1. Start the server, wait for a connection.
  server <- Server.Aff.createSecureServer
    (toOptions { key: key, cert: cert })
  Server.Aff.listenSecure server
    (toOptions { port: 8446 })
    \_session _headers stream -> do

      -- 2. Wait for the end of the request.
      parSequence_
        [ do
            trailers <- unsafePartial $ fromJust <$> Server.Aff.waitEnd stream
            console $ "SERVER Trailer " <> headersShow trailers
        , do
            _ <- readAll (Server.Aff.toDuplex stream)
            pure unit
        ]

      -- 3. Send a response
      Server.Aff.respond stream
        (toOptions { waitForTrailers: true })
        (toHeaders {})
      end (Server.Aff.toDuplex stream)
      Server.Aff.waitWantTrailers stream
      Server.Aff.sendTrailers stream (toHeaders { "trailer1": "response trailer" })

      -- After one session, stop the server.
      Server.Aff.closeSecureServer server

trailers_client :: Aff Unit
trailers_client = do

  -- 1. Begin the session, open a connection.
  session <- Client.Aff.connect
    (toOptions { ca: cert })
    (URL.parse "https://localhost:8446")

  -- 2. Send a request.
  stream <- Client.Aff.request session
    (toOptions { waitForTrailers: true, endStream: false })
    (toHeaders {})
  end (Client.Aff.toDuplex stream)
  Client.Aff.waitWantTrailers stream
  Client.Aff.sendTrailers stream (toHeaders { "trailer1": "request trailer" })

  -- 3. Wait for the response.
  headers <- Client.Aff.waitResponse stream
  console $ "CLIENT Header " <> headersShow headers

  -- 4. Wait for trailers.
  trailers <- unsafePartial $ fromJust <$> Client.Aff.waitEnd stream
  console $ "CLIENT Trailer " <> headersShow trailers

  -- 5. Close the connection.
  Client.Aff.closeSession session

headersShow :: HeadersObject -> String
headersShow headers = String.joinWith ", " $ headerKeys headers <#> \key ->
  key <> ": " <>
    ( fromMaybe "" $
        (headerString headers key)
          <|>
            (String.joinWith " " <$> headerArray headers key)
    )

error1_serverSecure :: Aff Unit
error1_serverSecure = catchError
  do
    -- 1. Start the server, wait for a connection.
    _ <- Server.Aff.createSecureServer
      (toOptions { key: "bad key", cert: "bad cert" })
    pure unit
  ( \e -> do
      console e
      throwError e
  )

error2_serverSecure :: Aff Unit
error2_serverSecure = catchError
  do
    -- 1. Start the server, wait for a connection.
    server <- Server.Aff.createSecureServer
      (toOptions { key: key, cert: cert })
    void $ Server.Aff.listenSecure server
      (toOptions { port: 1 })
      \_session _headers _stream -> pure unit
  ( \e -> do
      console e
      throwError e
  )

error1_client :: Aff Unit
error1_client = catchError
  do
    -- 1. Begin the session, open a connection.
    _ <- Client.Aff.connect
      (toOptions { ca: cert })
      (URL.parse "https://localhost:1")
    pure unit
  ( \e -> do
      console e
      throwError e
  )

error2_client :: Aff Unit
error2_client = catchError
  do
    -- 1. Begin the session, open a connection.
    session <- Client.Aff.connect
      (toOptions {})
      (URL.parse "https://www.google.com:443")
    stream <- Client.Aff.request session
      (toOptions {})
      (toHeaders { "bad header": "bad header" })
    headers <- Client.Aff.waitResponse stream
    console headers
  ( \e -> do
      console e
      throwError e
  )

cancel1_serverSecure :: Aff Unit
cancel1_serverSecure = do

  -- 1. Start the server, wait for a connection.
  server <- Server.Aff.createSecureServer
    (toOptions { key: key, cert: cert })
  fiber <- forkAff do
    void $ Server.Aff.listenSecure server
      (toOptions { port: 8447 })
      \_session _headers _stream -> do
        pure unit
  killFiber (error "no error") fiber
  Server.Aff.closeSecureServer server
