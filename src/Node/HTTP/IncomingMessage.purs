module Node.HTTP.IncomingMessage where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (Foreign)
import Foreign.Object (Object)
import Node.EventEmitter (EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0)
import Node.HTTP.Types (IMClientRequest, IMServer, IncomingMessage)
import Node.Stream (Readable, Duplex)
import Unsafe.Coerce (unsafeCoerce)

toReadable :: forall messageType. IncomingMessage messageType -> Readable ()
toReadable = unsafeCoerce

closeH :: forall messageType. EventHandle0 (IncomingMessage messageType)
closeH = EventHandle "close" identity

complete :: forall messageType. IncomingMessage messageType -> Effect Boolean
complete im = runEffectFn1 completeImpl im

foreign import completeImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Boolean)

headers :: forall messageType. IncomingMessage messageType -> Effect (Object Foreign)
headers im = runEffectFn1 headersImpl im

foreign import headersImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) ((Object Foreign))

headersDistinct :: forall messageType. IncomingMessage messageType -> Effect (Object (NonEmptyArray String))
headersDistinct im = runEffectFn1 headersDistinctImpl im

foreign import headersDistinctImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) ((Object (NonEmptyArray String)))

foreign import httpVersion :: forall messageType. IncomingMessage messageType -> String

foreign import method :: IncomingMessage IMServer -> String

foreign import rawHeaders :: forall messageType. IncomingMessage messageType -> Array String

rawTrailers :: forall messageType. IncomingMessage messageType -> Maybe (Array String)
rawTrailers im = toMaybe $ rawTrailersImpl im

foreign import rawTrailersImpl :: forall messageType. IncomingMessage messageType -> (Nullable (Array String))

socket :: forall messageType. IncomingMessage messageType -> Effect (Maybe Duplex)
socket im = map toMaybe $ runEffectFn1 socketImpl im

foreign import socketImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable Duplex)

foreign import statusCode :: IncomingMessage IMClientRequest -> Int

foreign import statusMessage :: IncomingMessage IMClientRequest -> String

trailers :: forall messageType. IncomingMessage messageType -> Effect (Maybe (Object Foreign))
trailers im = map toMaybe $ runEffectFn1 trailersImpl im

foreign import trailersImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable (Object Foreign))

trailersDistinct :: forall messageType. IncomingMessage messageType -> Effect (Maybe (Object (NonEmptyArray String)))
trailersDistinct im = map toMaybe $ runEffectFn1 trailersDistinctImpl im

foreign import trailersDistinctImpl :: forall messageType. EffectFn1 (IncomingMessage messageType) (Nullable (Object (NonEmptyArray String)))

foreign import url :: IncomingMessage IMServer -> String

