module Node.HTTP.IncomingMessage
  ( toReadable
  , closeH
  , complete
  , headers
  , cookies
  , headersDistinct
  , httpVersion
  , method
  , rawHeaders
  , rawTrailers
  , socket
  , statusCode
  , statusMessage
  , trailers
  , trailersDistinct
  , url
  ) where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (Foreign)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0)
import Node.HTTP.Types (IMClientRequest, IMServer, IncomingMessage)
import Node.Net.Types (Socket, TCP)
import Node.Stream (Readable)
import Unsafe.Coerce (unsafeCoerce)

toReadable :: forall messageType. IncomingMessage messageType -> Readable ()
toReadable = unsafeCoerce

closeH :: forall messageType. EventHandle0 (IncomingMessage messageType)
closeH = EventHandle "close" identity

complete :: forall messageType. IncomingMessage messageType -> Effect Boolean
complete im = runEffectFn1 completeImpl im

foreign import completeImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Boolean)

headers :: forall messageType. IncomingMessage messageType -> Object String
headers = Object.delete "set-cookie" <<< headersImpl

cookies :: forall messageType. IncomingMessage messageType -> Maybe (Array String)
cookies = Object.lookup "set-cookie" <<< headersImpl

foreign import headersImpl :: forall messageType a. IncomingMessage messageType -> Object a

foreign import headersDistinct :: forall messageType. IncomingMessage messageType -> Object (NonEmptyArray String)

foreign import httpVersion :: forall messageType. IncomingMessage messageType -> String

foreign import method :: IncomingMessage IMServer -> String

foreign import rawHeaders :: forall messageType. IncomingMessage messageType -> Array String

rawTrailers :: forall messageType. IncomingMessage messageType -> Maybe (Array String)
rawTrailers im = toMaybe $ rawTrailersImpl im

foreign import rawTrailersImpl :: forall messageType. IncomingMessage messageType -> (Nullable (Array String))

socket :: forall messageType. IncomingMessage messageType -> Effect (Maybe (Socket TCP))
socket im = map toMaybe $ runEffectFn1 socketImpl im

foreign import socketImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable (Socket TCP))

foreign import statusCode :: IncomingMessage IMClientRequest -> Int

foreign import statusMessage :: IncomingMessage IMClientRequest -> String

trailers :: forall messageType. IncomingMessage messageType -> Effect (Maybe (Object Foreign))
trailers im = map toMaybe $ runEffectFn1 trailersImpl im

foreign import trailersImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable (Object Foreign))

trailersDistinct :: forall messageType. IncomingMessage messageType -> Effect (Maybe (Object (NonEmptyArray String)))
trailersDistinct im = map toMaybe $ runEffectFn1 trailersDistinctImpl im

foreign import trailersDistinctImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable (Object (NonEmptyArray String)))

foreign import url :: IncomingMessage IMServer -> String

