module Node.HTTP.ServerResponse
  ( toOutgoingMessage
  , closeH
  , finishH
  , req
  , sendDate
  , setSendDate
  , statusCode
  , setStatusCode
  , statusMessage
  , setStatusMessage
  , strictContentLength
  , setStrictContentLength
  , writeEarlyHints
  , writeEarlyHints'
  , writeHead
  , writeHead'
  , writeHeadHeaders
  , writeHeadMsgHeaders
  , writeProcessing
  ) where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, runEffectFn1, runEffectFn2, runEffectFn3, runEffectFn4)
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0)
import Node.HTTP.Types (IMServer, IncomingMessage, OutgoingMessage, ServerResponse)
import Unsafe.Coerce (unsafeCoerce)

toOutgoingMessage :: ServerResponse -> OutgoingMessage
toOutgoingMessage = unsafeCoerce

closeH :: EventHandle0 ServerResponse
closeH = EventHandle "close" identity

finishH :: EventHandle0 ServerResponse
finishH = EventHandle "finish" identity

foreign import req :: ServerResponse -> IncomingMessage IMServer

sendDate :: ServerResponse -> Effect Boolean
sendDate sr = runEffectFn1 sendDateImpl sr

foreign import sendDateImpl :: EffectFn1 (ServerResponse) (Boolean)

setSendDate :: Boolean -> ServerResponse -> Effect Unit
setSendDate b sr = runEffectFn2 setSendDateImpl b sr

foreign import setSendDateImpl :: EffectFn2 (Boolean) (ServerResponse) (Unit)

statusCode :: ServerResponse -> Effect Int
statusCode sr = runEffectFn1 statusCodeImpl sr

foreign import statusCodeImpl :: EffectFn1 (ServerResponse) (Int)

setStatusCode :: Int -> ServerResponse -> Effect Unit
setStatusCode code sr = runEffectFn2 setStatusCodeImpl code sr

foreign import setStatusCodeImpl :: EffectFn2 (Int) (ServerResponse) (Unit)

statusMessage :: ServerResponse -> Effect String
statusMessage sr = runEffectFn1 statusMessageImpl sr

foreign import statusMessageImpl :: EffectFn1 (ServerResponse) (String)

setStatusMessage :: String -> ServerResponse -> Effect Unit
setStatusMessage msg sr = runEffectFn2 setStatusMessageImpl msg sr

foreign import setStatusMessageImpl :: EffectFn2 (String) (ServerResponse) (Unit)

strictContentLength :: ServerResponse -> Effect Boolean
strictContentLength sr = runEffectFn1 strictContentLengthImpl sr

foreign import strictContentLengthImpl :: EffectFn1 (ServerResponse) (Boolean)

setStrictContentLength :: Boolean -> ServerResponse -> Effect Unit
setStrictContentLength b sr = runEffectFn2 setStrictContentLengthImpl b sr

foreign import setStrictContentLengthImpl :: EffectFn2 (Boolean) (ServerResponse) (Unit)

writeEarlyHints :: forall r. { | r } -> ServerResponse -> Effect Unit
writeEarlyHints hints sr = runEffectFn2 writeEarlyHintsImpl hints sr

foreign import writeEarlyHintsImpl :: forall r. EffectFn2 ({ | r }) (ServerResponse) (Unit)

writeEarlyHints' :: forall r. { | r } -> Effect Unit -> ServerResponse -> Effect Unit
writeEarlyHints' hints cb sr = runEffectFn3 writeEarlyHintsCbImpl hints cb sr

foreign import writeEarlyHintsCbImpl :: forall r. EffectFn3 ({ | r }) (Effect Unit) (ServerResponse) (Unit)

writeHead :: Int -> ServerResponse -> Effect Unit
writeHead statusCode' sr = runEffectFn2 writeHeadImpl statusCode' sr

foreign import writeHeadImpl :: EffectFn2 (Int) (ServerResponse) (Unit)

writeHead' :: Int -> String -> ServerResponse -> Effect Unit
writeHead' statusCode' statusMsg sr = runEffectFn3 writeHeadMsgImpl statusCode' statusMsg sr

foreign import writeHeadMsgImpl :: EffectFn3 (Int) (String) (ServerResponse) (Unit)

writeHeadHeaders :: forall r. Int -> { | r } -> ServerResponse -> Effect Unit
writeHeadHeaders statusCode' hdrs sr = runEffectFn3 writeHeadHeadersImpl statusCode' hdrs sr

foreign import writeHeadHeadersImpl :: forall r. EffectFn3 (Int) ({ | r }) (ServerResponse) (Unit)

writeHeadMsgHeaders :: forall r. Int -> String -> { | r } -> ServerResponse -> Effect Unit
writeHeadMsgHeaders statusCode' msg hdrs sr = runEffectFn4 writeHeadMsgHeadersImpl statusCode' msg hdrs sr

foreign import writeHeadMsgHeadersImpl :: forall r. EffectFn4 (Int) (String) ({ | r }) (ServerResponse) (Unit)

writeProcessing :: ServerResponse -> Effect Unit
writeProcessing sr = runEffectFn1 writeProcessingImpl sr

foreign import writeProcessingImpl :: EffectFn1 (ServerResponse) (Unit)
