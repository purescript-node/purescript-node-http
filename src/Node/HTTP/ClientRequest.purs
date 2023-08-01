module Node.HTTP.ClientRequest
  ( toOutgoingMessage
  , closeH
  , connectH
  , continueH
  , finishH
  , informationH
  , responseH
  , socketH
  , timeoutH
  , upgradeH
  , path
  , method
  , host
  , protocol
  , reusedSocket
  , setNoDelay
  , setSocketKeepAlive
  , setTimeout
  ) where

import Prelude

import Data.Time.Duration (Milliseconds)
import Effect (Effect)
import Effect.Uncurried (EffectFn2, EffectFn3, mkEffectFn1, mkEffectFn3, runEffectFn2, runEffectFn3)
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.Buffer (Buffer)
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0, EventHandle3, EventHandle1)
import Node.HTTP.Types (ClientRequest, IMClientRequest, IncomingMessage, OutgoingMessage)
import Node.Net.Types (Socket, TCP)
import Unsafe.Coerce (unsafeCoerce)

toOutgoingMessage :: ClientRequest -> OutgoingMessage
toOutgoingMessage = unsafeCoerce

closeH :: EventHandle0 ClientRequest
closeH = EventHandle "close" identity

connectH :: EventHandle3 ClientRequest (IncomingMessage IMClientRequest) (Socket TCP) Buffer
connectH = EventHandle "connect" \cb -> mkEffectFn3 \a b c -> cb a b c

continueH :: EventHandle0 ClientRequest
continueH = EventHandle "continue" identity

finishH :: EventHandle0 ClientRequest
finishH = EventHandle "finish" identity

informationH
  :: EventHandle1 ClientRequest
       { httpVersion :: String
       , httpVersionMajor :: Int
       , httpVersionMinor :: Int
       , statusCode :: Int
       , statusMessage :: String
       , headers :: Object Foreign
       , rawHeaders :: Array String
       }
informationH = EventHandle "information" mkEffectFn1

responseH :: EventHandle1 ClientRequest (IncomingMessage IMClientRequest)
responseH = EventHandle "response" mkEffectFn1

socketH :: EventHandle1 ClientRequest (Socket TCP)
socketH = EventHandle "socket" mkEffectFn1

timeoutH :: EventHandle0 ClientRequest
timeoutH = EventHandle "timeout" identity

upgradeH :: EventHandle3 ClientRequest (IncomingMessage IMClientRequest) (Socket TCP) Buffer
upgradeH = EventHandle "upgrade" \cb -> mkEffectFn3 \a b c -> cb a b c

foreign import path :: ClientRequest -> String
foreign import method :: ClientRequest -> String
foreign import host :: ClientRequest -> String
foreign import protocol :: ClientRequest -> String
foreign import reusedSocket :: ClientRequest -> Boolean

setNoDelay :: Boolean -> ClientRequest -> Effect Unit
setNoDelay d cr = runEffectFn2 setNoDelayImpl d cr

foreign import setNoDelayImpl :: EffectFn2 (Boolean) (ClientRequest) (Unit)

setSocketKeepAlive :: Boolean -> Milliseconds -> ClientRequest -> Effect Unit
setSocketKeepAlive d ms cr = runEffectFn3 setSocketKeepAliveImpl d ms cr

foreign import setSocketKeepAliveImpl :: EffectFn3 (Boolean) (Milliseconds) (ClientRequest) (Unit)

setTimeout :: Milliseconds -> ClientRequest -> Effect Unit
setTimeout ms cr = runEffectFn2 setTimeoutImpl ms cr

foreign import setTimeoutImpl :: EffectFn2 (Milliseconds) (ClientRequest) (Unit)

