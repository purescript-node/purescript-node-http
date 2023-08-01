module Node.HTTP.OutgoingMessage
  ( toWriteable
  , drainH
  , finishH
  , prefinishH
  , addTrailers
  , appendHeader
  , appendHeaders
  , flushHeaders
  , getHeader
  , getHeaderNames
  , getHeaders
  , hasHeader
  , headersSent
  , removeHeader
  , setHeader
  , setHeader'
  , setTimeout
  , socket
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.Time.Duration (Milliseconds)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, runEffectFn1, runEffectFn2, runEffectFn3)
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0)
import Node.HTTP.Types (OutgoingMessage)
import Node.Net.Types (Socket, TCP)
import Node.Stream (Writable)
import Unsafe.Coerce (unsafeCoerce)

toWriteable :: OutgoingMessage -> Writable ()
toWriteable = unsafeCoerce

drainH :: EventHandle0 OutgoingMessage
drainH = EventHandle "drain" identity

finishH :: EventHandle0 OutgoingMessage
finishH = EventHandle "finish" identity

prefinishH :: EventHandle0 OutgoingMessage
prefinishH = EventHandle "prefinish" identity

addTrailers :: Object String -> OutgoingMessage -> Effect Unit
addTrailers trailers msg = runEffectFn2 addTrailersImpl trailers msg

foreign import addTrailersImpl :: EffectFn2 (Object String) (OutgoingMessage) (Unit)

appendHeader :: String -> String -> OutgoingMessage -> Effect Unit
appendHeader name value msg = runEffectFn3 appendHeaderImpl name value msg

foreign import appendHeaderImpl :: EffectFn3 (String) (String) (OutgoingMessage) (Unit)

appendHeaders :: String -> Array String -> OutgoingMessage -> Effect Unit
appendHeaders name values msg = runEffectFn3 appendHeadersImpl name values msg

foreign import appendHeadersImpl :: EffectFn3 (String) (Array String) (OutgoingMessage) (Unit)

flushHeaders :: OutgoingMessage -> Effect Unit
flushHeaders msg = runEffectFn1 flushHeadersImpl msg

foreign import flushHeadersImpl :: EffectFn1 (OutgoingMessage) (Unit)

getHeader :: String -> OutgoingMessage -> Effect (Maybe String)
getHeader name msg = map toMaybe $ runEffectFn2 getHeaderImpl name msg

foreign import getHeaderImpl :: EffectFn2 (String) (OutgoingMessage) (Nullable String)

getHeaderNames :: String -> OutgoingMessage -> Effect (Array String)
getHeaderNames name msg = runEffectFn2 getHeaderNamesImpl name msg

foreign import getHeaderNamesImpl :: EffectFn2 (String) (OutgoingMessage) ((Array String))

getHeaders :: OutgoingMessage -> Effect (Object Foreign)
getHeaders msg = runEffectFn1 getHeadersImpl msg

foreign import getHeadersImpl :: EffectFn1 (OutgoingMessage) (Object Foreign)

hasHeader :: String -> OutgoingMessage -> Effect Boolean
hasHeader name msg = runEffectFn2 hasHeaderImpl name msg

foreign import hasHeaderImpl :: EffectFn2 (String) (OutgoingMessage) (Boolean)

headersSent :: OutgoingMessage -> Effect Boolean
headersSent msg = runEffectFn1 headersSentImpl msg

foreign import headersSentImpl :: EffectFn1 (OutgoingMessage) (Boolean)

removeHeader :: String -> OutgoingMessage -> Effect Unit
removeHeader name msg = runEffectFn2 removeHeaderImpl name msg

foreign import removeHeaderImpl :: EffectFn2 (String) (OutgoingMessage) (Unit)

setHeader :: String -> String -> OutgoingMessage -> Effect Unit
setHeader name value msg = runEffectFn3 setHeaderImpl name value msg

foreign import setHeaderImpl :: EffectFn3 (String) (String) (OutgoingMessage) (Unit)

setHeader' :: String -> Array String -> OutgoingMessage -> Effect Unit
setHeader' name value msg = runEffectFn3 setHeaderArrImpl name value msg

foreign import setHeaderArrImpl :: EffectFn3 (String) (Array String) (OutgoingMessage) (Unit)

setTimeout :: Milliseconds -> OutgoingMessage -> Effect Unit
setTimeout msecs msg = runEffectFn2 setTimeoutImpl msecs msg

foreign import setTimeoutImpl :: EffectFn2 (Milliseconds) (OutgoingMessage) (Unit)

socket :: OutgoingMessage -> Effect (Maybe (Socket TCP))
socket msg = map toMaybe $ runEffectFn1 socketImpl msg

foreign import socketImpl :: EffectFn1 (OutgoingMessage) (Nullable (Socket TCP))
