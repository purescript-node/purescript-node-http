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
import Node.HTTP.Types (IncomingMessage)
import Node.Stream (Readable, Duplex)
import Unsafe.Coerce (unsafeCoerce)

toReadable :: IncomingMessage -> Readable ()
toReadable = unsafeCoerce

closeH :: EventHandle0 IncomingMessage
closeH = EventHandle "close" identity

complete :: IncomingMessage -> Effect Boolean
complete im = runEffectFn1 completeImpl im

foreign import completeImpl :: EffectFn1 (IncomingMessage) (Boolean)

headers :: IncomingMessage -> Effect (Object Foreign)
headers im = runEffectFn1 headersImpl im

foreign import headersImpl :: EffectFn1 (IncomingMessage) ((Object Foreign))

headersDistinct :: IncomingMessage -> Effect (Object (NonEmptyArray String))
headersDistinct im = runEffectFn1 headersDistinctImpl im

foreign import headersDistinctImpl :: EffectFn1 (IncomingMessage) ((Object (NonEmptyArray String)))

foreign import httpVersion :: IncomingMessage -> String

-- if obtained from `http.Server`
foreign import method :: IncomingMessage -> String

foreign import rawHeaders :: IncomingMessage -> Array String

rawTrailers :: IncomingMessage -> Maybe (Array String)
rawTrailers im = toMaybe $ rawTrailersImpl im

foreign import rawTrailersImpl :: IncomingMessage -> (Nullable (Array String))

socket :: IncomingMessage -> Effect (Maybe Duplex)
socket im = map toMaybe $ runEffectFn1 socketImpl im

foreign import socketImpl :: EffectFn1 (IncomingMessage) (Nullable Duplex)

-- if obtained from `http.ClientRequest`
foreign import statusCode :: IncomingMessage -> Int

-- if obtained from `http.ClientRequest`
foreign import statusMessage :: IncomingMessage -> String

trailers :: IncomingMessage -> Effect (Maybe (Object Foreign))
trailers im = map toMaybe $ runEffectFn1 trailersImpl im

foreign import trailersImpl :: EffectFn1 (IncomingMessage) (Nullable (Object Foreign))

trailersDistinct :: IncomingMessage -> Effect (Maybe (Object (NonEmptyArray String)))
trailersDistinct im = map toMaybe $ runEffectFn1 trailersDistinctImpl im

foreign import trailersDistinctImpl :: EffectFn1 (IncomingMessage) (Nullable (Object (NonEmptyArray String)))

-- if obtained from `http.Server`
foreign import url :: IncomingMessage -> String

