module Node.HTTP.Server
  ( toNetServer
  , checkContinueH
  , checkExpectationH
  , ClientErrorException
  , toError
  , bytesParsed
  , rawPacket
  , clientErrorH
  , closeH
  , connectH
  , connectionH
  , dropRequestH
  , requestH
  , upgradeH
  , closeAllConnections
  , closeIdleConnections
  , headersTimeout
  , setHeadersTimeout
  , maxHeadersCount
  , setMaxHeadersCount
  , setUnlimitedHeadersCount
  , requestTimeout
  , setRequestTimeout
  , maxRequestsPerSocket
  , setMaxRequestsPerSocket
  , setUnlimitedRequestsPerSocket
  , timeout
  , setTimeout
  , clearTimeout
  , keepAliveTimeout
  , setKeepAliveTimeout
  , clearKeepAliveTimeout

  ) where

import Prelude

import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn1, EffectFn2, mkEffectFn1, mkEffectFn2, mkEffectFn3, runEffectFn1, runEffectFn2)
import Foreign (Foreign)
import Node.Buffer (Buffer)
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0, EventHandle2, EventHandle3, EventHandle1)
import Node.HTTP.Types (HttpServer, IMServer, IncomingMessage, ServerResponse)
import Node.Net.Types (Server, TCP)
import Node.Stream (Duplex)
import Unsafe.Coerce (unsafeCoerce)

toNetServer :: HttpServer -> Server TCP
toNetServer = unsafeCoerce

checkContinueH :: EventHandle2 HttpServer (IncomingMessage IMServer) ServerResponse
checkContinueH = EventHandle "checkContinue" \cb -> mkEffectFn2 \a b -> cb a b

checkExpectationH :: EventHandle2 HttpServer (IncomingMessage IMServer) ServerResponse
checkExpectationH = EventHandle "checkExpectation" \cb -> mkEffectFn2 \a b -> cb a b

newtype ClientErrorException = ClientErrorException Error

toError :: ClientErrorException -> Error
toError (ClientErrorException e) = e

foreign import bytesParsed :: ClientErrorException -> Int
foreign import rawPacket :: ClientErrorException -> Foreign

clientErrorH :: EventHandle2 HttpServer ClientErrorException Duplex
clientErrorH = EventHandle "clientError" \cb -> mkEffectFn2 \a b -> cb a b

closeH :: EventHandle0 HttpServer
closeH = EventHandle "close" identity

connectH :: EventHandle3 HttpServer (IncomingMessage IMServer) Duplex Buffer
connectH = EventHandle "connect" \cb -> mkEffectFn3 \a b c -> cb a b c

connectionH :: EventHandle1 HttpServer Duplex
connectionH = EventHandle "connection" mkEffectFn1

dropRequestH :: EventHandle2 HttpServer (IncomingMessage IMServer) Duplex
dropRequestH = EventHandle "dropRequest" \cb -> mkEffectFn2 \a b -> cb a b

requestH :: EventHandle2 HttpServer (IncomingMessage IMServer) ServerResponse
requestH = EventHandle "request" \cb -> mkEffectFn2 \a b -> cb a b

upgradeH :: EventHandle3 HttpServer (IncomingMessage IMServer) Duplex Buffer
upgradeH = EventHandle "upgrade" \cb -> mkEffectFn3 \a b c -> cb a b c

closeAllConnections :: HttpServer -> Effect Unit
closeAllConnections hs = runEffectFn1 closeAllConnectionsImpl hs

foreign import closeAllConnectionsImpl :: EffectFn1 (HttpServer) (Unit)

closeIdleConnections :: HttpServer -> Effect Unit
closeIdleConnections hs = runEffectFn1 closeIdleConnectionsImpl hs

foreign import closeIdleConnectionsImpl :: EffectFn1 (HttpServer) (Unit)

headersTimeout :: HttpServer -> Effect Int
headersTimeout hs = runEffectFn1 headersTimeoutImpl hs

foreign import headersTimeoutImpl :: EffectFn1 (HttpServer) (Int)

setHeadersTimeout :: Int -> HttpServer -> Effect Unit
setHeadersTimeout tm hs = runEffectFn2 setHeadersTimeoutImpl tm hs

foreign import setHeadersTimeoutImpl :: EffectFn2 (Int) (HttpServer) (Unit)

maxHeadersCount :: HttpServer -> Effect Int
maxHeadersCount hs = runEffectFn1 maxHeadersCountImpl hs

foreign import maxHeadersCountImpl :: EffectFn1 (HttpServer) (Int)

setMaxHeadersCount :: Int -> HttpServer -> Effect Unit
setMaxHeadersCount c hs = runEffectFn2 setMaxHeadersCountImpl c hs

foreign import setMaxHeadersCountImpl :: EffectFn2 (Int) (HttpServer) (Unit)

setUnlimitedHeadersCount :: HttpServer -> Effect Unit
setUnlimitedHeadersCount = setMaxHeadersCount 0

requestTimeout :: HttpServer -> Effect Milliseconds
requestTimeout hs = runEffectFn1 requestTimeoutImpl hs

foreign import requestTimeoutImpl :: EffectFn1 (HttpServer) (Milliseconds)

setRequestTimeout :: Milliseconds -> HttpServer -> Effect Unit
setRequestTimeout tm hs = runEffectFn2 setRequestTimeoutImpl tm hs

foreign import setRequestTimeoutImpl :: EffectFn2 (Milliseconds) (HttpServer) (Unit)

maxRequestsPerSocket :: HttpServer -> Effect Int
maxRequestsPerSocket hs = runEffectFn1 maxRequestsPerSocketImpl hs

foreign import maxRequestsPerSocketImpl :: EffectFn1 (HttpServer) (Int)

setMaxRequestsPerSocket :: Int -> HttpServer -> Effect Unit
setMaxRequestsPerSocket c hs = runEffectFn2 setMaxRequestsPerSocketImpl c hs

foreign import setMaxRequestsPerSocketImpl :: EffectFn2 (Int) (HttpServer) (Unit)

setUnlimitedRequestsPerSocket :: HttpServer -> Effect Unit
setUnlimitedRequestsPerSocket hs = setMaxRequestsPerSocket 0 hs

timeout :: HttpServer -> Effect Milliseconds
timeout hs = runEffectFn1 timeoutImpl hs

foreign import timeoutImpl :: EffectFn1 (HttpServer) (Milliseconds)

setTimeout :: Milliseconds -> HttpServer -> Effect Unit
setTimeout ms hs = runEffectFn2 setTimeoutImpl ms hs

foreign import setTimeoutImpl :: EffectFn2 (Milliseconds) (HttpServer) (Unit)

clearTimeout :: HttpServer -> Effect Unit
clearTimeout hs = setTimeout (Milliseconds 0.0) hs

keepAliveTimeout :: HttpServer -> Effect Milliseconds
keepAliveTimeout hs = runEffectFn1 keepAliveTimeoutImpl hs

foreign import keepAliveTimeoutImpl :: EffectFn1 (HttpServer) (Milliseconds)

setKeepAliveTimeout :: Milliseconds -> HttpServer -> Effect Unit
setKeepAliveTimeout ms hs = runEffectFn2 setKeepAliveTimeoutImpl ms hs

foreign import setKeepAliveTimeoutImpl :: EffectFn2 (Milliseconds) (HttpServer) (Unit)

clearKeepAliveTimeout :: HttpServer -> Effect Unit
clearKeepAliveTimeout hs = setKeepAliveTimeout (Milliseconds 0.0) hs
