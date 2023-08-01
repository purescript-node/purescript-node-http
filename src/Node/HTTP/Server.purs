module Node.HTTP.Server
  ( toTlsServer
  , toNetServer
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
import Node.HTTP.Types (Encrypted, HttpServer', IMServer, IncomingMessage, ServerResponse)
import Node.Net.Types (Server, Socket, TCP)
import Node.Stream (Duplex)
import Node.TLS.Types (TlsServer)
import Unsafe.Coerce (unsafeCoerce)

toTlsServer :: HttpServer' Encrypted -> TlsServer
toTlsServer = unsafeCoerce

toNetServer :: forall transmissionType. (HttpServer' transmissionType) -> Server TCP
toNetServer = unsafeCoerce

checkContinueH :: forall transmissionType. EventHandle2 (HttpServer' transmissionType) (IncomingMessage IMServer) ServerResponse
checkContinueH = EventHandle "checkContinue" \cb -> mkEffectFn2 \a b -> cb a b

checkExpectationH :: forall transmissionType. EventHandle2 (HttpServer' transmissionType) (IncomingMessage IMServer) ServerResponse
checkExpectationH = EventHandle "checkExpectation" \cb -> mkEffectFn2 \a b -> cb a b

newtype ClientErrorException = ClientErrorException Error

toError :: ClientErrorException -> Error
toError (ClientErrorException e) = e

foreign import bytesParsed :: ClientErrorException -> Int
foreign import rawPacket :: ClientErrorException -> Foreign

clientErrorH :: forall transmissionType. EventHandle2 (HttpServer' transmissionType) ClientErrorException Duplex
clientErrorH = EventHandle "clientError" \cb -> mkEffectFn2 \a b -> cb a b

closeH :: forall transmissionType. EventHandle0 (HttpServer' transmissionType)
closeH = EventHandle "close" identity

connectH :: forall transmissionType. EventHandle3 (HttpServer' transmissionType) (IncomingMessage IMServer) (Socket TCP) Buffer
connectH = EventHandle "connect" \cb -> mkEffectFn3 \a b c -> cb a b c

connectionH :: forall transmissionType. EventHandle1 (HttpServer' transmissionType) Duplex
connectionH = EventHandle "connection" mkEffectFn1

dropRequestH :: forall transmissionType. EventHandle2 (HttpServer' transmissionType) (IncomingMessage IMServer) Duplex
dropRequestH = EventHandle "dropRequest" \cb -> mkEffectFn2 \a b -> cb a b

requestH :: forall transmissionType. EventHandle2 (HttpServer' transmissionType) (IncomingMessage IMServer) ServerResponse
requestH = EventHandle "request" \cb -> mkEffectFn2 \a b -> cb a b

upgradeH :: forall transmissionType. EventHandle3 (HttpServer' transmissionType) (IncomingMessage IMServer) (Socket TCP) Buffer
upgradeH = EventHandle "upgrade" \cb -> mkEffectFn3 \a b c -> cb a b c

closeAllConnections :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
closeAllConnections hs = runEffectFn1 closeAllConnectionsImpl hs

foreign import closeAllConnectionsImpl :: forall transmissionType. EffectFn1 (HttpServer' transmissionType) (Unit)

closeIdleConnections :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
closeIdleConnections hs = runEffectFn1 closeIdleConnectionsImpl hs

foreign import closeIdleConnectionsImpl :: forall transmissionType. EffectFn1 (HttpServer' transmissionType) (Unit)

headersTimeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Int
headersTimeout hs = runEffectFn1 headersTimeoutImpl hs

foreign import headersTimeoutImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Int)

setHeadersTimeout :: forall transmissionType. Int -> (HttpServer' transmissionType) -> Effect Unit
setHeadersTimeout tm hs = runEffectFn2 setHeadersTimeoutImpl tm hs

foreign import setHeadersTimeoutImpl :: forall transmissionType. EffectFn2 (Int) ((HttpServer' transmissionType)) (Unit)

maxHeadersCount :: forall transmissionType. (HttpServer' transmissionType) -> Effect Int
maxHeadersCount hs = runEffectFn1 maxHeadersCountImpl hs

foreign import maxHeadersCountImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Int)

setMaxHeadersCount :: forall transmissionType. Int -> (HttpServer' transmissionType) -> Effect Unit
setMaxHeadersCount c hs = runEffectFn2 setMaxHeadersCountImpl c hs

foreign import setMaxHeadersCountImpl :: forall transmissionType. EffectFn2 (Int) ((HttpServer' transmissionType)) (Unit)

setUnlimitedHeadersCount :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
setUnlimitedHeadersCount = setMaxHeadersCount 0

requestTimeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Milliseconds
requestTimeout hs = runEffectFn1 requestTimeoutImpl hs

foreign import requestTimeoutImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Milliseconds)

setRequestTimeout :: forall transmissionType. Milliseconds -> (HttpServer' transmissionType) -> Effect Unit
setRequestTimeout tm hs = runEffectFn2 setRequestTimeoutImpl tm hs

foreign import setRequestTimeoutImpl :: forall transmissionType. EffectFn2 (Milliseconds) ((HttpServer' transmissionType)) (Unit)

maxRequestsPerSocket :: forall transmissionType. (HttpServer' transmissionType) -> Effect Int
maxRequestsPerSocket hs = runEffectFn1 maxRequestsPerSocketImpl hs

foreign import maxRequestsPerSocketImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Int)

setMaxRequestsPerSocket :: forall transmissionType. Int -> (HttpServer' transmissionType) -> Effect Unit
setMaxRequestsPerSocket c hs = runEffectFn2 setMaxRequestsPerSocketImpl c hs

foreign import setMaxRequestsPerSocketImpl :: forall transmissionType. EffectFn2 (Int) ((HttpServer' transmissionType)) (Unit)

setUnlimitedRequestsPerSocket :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
setUnlimitedRequestsPerSocket hs = setMaxRequestsPerSocket 0 hs

timeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Milliseconds
timeout hs = runEffectFn1 timeoutImpl hs

foreign import timeoutImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Milliseconds)

setTimeout :: forall transmissionType. Milliseconds -> (HttpServer' transmissionType) -> Effect Unit
setTimeout ms hs = runEffectFn2 setTimeoutImpl ms hs

foreign import setTimeoutImpl :: forall transmissionType. EffectFn2 (Milliseconds) ((HttpServer' transmissionType)) (Unit)

clearTimeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
clearTimeout hs = setTimeout (Milliseconds 0.0) hs

keepAliveTimeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Milliseconds
keepAliveTimeout hs = runEffectFn1 keepAliveTimeoutImpl hs

foreign import keepAliveTimeoutImpl :: forall transmissionType. EffectFn1 ((HttpServer' transmissionType)) (Milliseconds)

setKeepAliveTimeout :: forall transmissionType. Milliseconds -> (HttpServer' transmissionType) -> Effect Unit
setKeepAliveTimeout ms hs = runEffectFn2 setKeepAliveTimeoutImpl ms hs

foreign import setKeepAliveTimeoutImpl :: forall transmissionType. EffectFn2 (Milliseconds) ((HttpServer' transmissionType)) (Unit)

clearKeepAliveTimeout :: forall transmissionType. (HttpServer' transmissionType) -> Effect Unit
clearKeepAliveTimeout hs = setKeepAliveTimeout (Milliseconds 0.0) hs
