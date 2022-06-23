-- | Bindings to the [*Node.js* HTTP/2](https://nodejs.org/docs/latest/api/http2.html) API.
-- |
-- | ## `Effect` event-callback asynchronous API
-- |
-- | The __Node.HTTP2.Client__ and __Node.HTTP2.Server__ modules provide a
-- | low-level `Effect` event-callback API which is a thin FFI wrapper
-- | around the __*Node.js* HTTP/2__ types and functions.
-- |
-- | ## `Aff` asynchronous API
-- |
-- | The __Node.HTTP2.Client.Aff__ and __Node.HTTP2.Server.Aff__ modules provide
-- | a high-level asynchronous `Aff` API so that
-- | [“you don’t even have to think about callbacks.”](https://github.com/purescript-contrib/purescript-aff/tree/main/docs#escaping-callback-hell)
-- | That’s nice because when we attach callbacks to every possible event
-- | and then handle the events, it’s hard to keep track of the order
-- | in which events are occuring, and what context we’re in when an event
-- | handler is called.
-- |
-- | With the `Aff` API we can write HTTP/2 clients and services in plain flat
-- | one-thing-after-another
-- | effect style. But network peers are perverse and they may not
-- | send things to us in the order in which we expect. So we will want to
-- | reintroduce some of the indeterminacy that we get from an event-callback
-- | API. That’s what the
-- | [`Parallel ParAff Aff`](https://pursuit.purescript.org/packages/purescript-aff/docs/Effect.Aff#t:ParAff)
-- | instance is for.
-- | We can use the functions in
-- | [`Control.Parallel`](https://pursuit.purescript.org/packages/purescript-parallel/docs/Control.Parallel)
-- | to run `Aff` effects concurrently.
-- |
-- | #### Example: Asynchronous client and server
-- |
-- | Consider a function `push1_secureServer :: Aff Unit` which runs an
-- | HTTP/2 server that
-- | [pushes an extra HTTP/2 stream](https://en.wikipedia.org/wiki/HTTP/2_Server_Push)
-- | to its clients.
-- | This function does the following steps.
-- |
-- | 1. Wait for a connection.
-- | 2. Wait to receive a request.
-- | 3. Send a response stream.
-- | 4. Push a new stream, send the stream.
-- | 5. Close the connection.
-- |
-- | Also consider a function `push1_client :: Aff Unit` which opens an
-- | HTTP/2 client connection that can receive pushed streams.
-- | This function does the following steps.
-- |
-- | 1. Open a connection.
-- | 2. Wait for the connection, then send a request.
-- | 3. We have to do the next
-- |    two steps concurrently because we don't know whether the server
-- |    will send the main response stream or the pushed stream first.
-- |    And we don’t know which stream will complete first, either.
-- |
-- |    - 3a. Wait for the response stream.
-- |    - 3b. Wait for a pushed stream.
-- |
-- | 4. Wait for the connection to close.
-- |
-- | With `Aff`, we can __run both of these functions at the same time in
-- | the same thread and connect them to each other__.
-- | There’s a lot of asynchronous back-and-forth going on here,
-- | with each function waiting for the other one at multiple points.
-- | So how do we run
-- | these two functions concurrently without deadlocking?
-- | With [`Control.Parallel.parSequence_`](https://pursuit.purescript.org/packages/purescript-parallel/6.0.0/docs/Control.Parallel#v:parSequence):
-- |
-- | ```
-- | parSequence_
-- |   [ push1_secureServer
-- |   , push1_client
-- |   ]
-- | ```
-- |
-- | If you haven’t programmed with an asynchronous effect monad like `Aff`
-- | before, I hope this gives you an idea of how wieldy asynchronous
-- | effect monads are.
-- |
-- | This pair of functions is the `push1` test in our `HTTP2Aff`
-- | test suite.
-- | You can see the definitions
-- | for `push1_secureServer` and `push1_client` in
-- | [`test/HTTP2Aff.purs`](https://github.com/purescript-node/purescript-node-http/tree/master/test/HTTP2Aff.purs).
-- |
-- | #### Aff Idiom: Concurrent effects with homogeneous return values.
-- |
-- | We have `operation1`, `operation2`, and `operation3`, which are
-- | all side-effecting `Aff Unit` operations. We want to start them
-- | all at the same time. We don’t know in what order they’ll complete,
-- | but we want to wait until they’ve all completed before we continue.
-- |
-- | ```
-- | parSequence_
-- |   [ operation1
-- |   , operation2
-- |   , operation3
-- |   ]
-- | ```
-- |
-- | We can also use do-blocks in this idiom. And collect the results
-- | if the results are all some interesting type instead of `Unit`.
-- |
-- | ```
-- | [result1, result2, result3] <- parSequence
-- |   [ do
-- |       operation1
-- |   , do
-- |       operation2
-- |   , do
-- |       operation3
-- |   ]
-- | ```
-- |
-- | #### Aff Idiom: Concurrent effects with heterogeneous return values
-- |
-- | We have `operation1`, `operation2`, and `operation3`, which are
-- | all `Aff` operations with return values of different types.
-- | We want to start them
-- | all at the same time. We don’t know in what order they’ll complete,
-- | but we need all of their results before we can continue.
-- | We can collect their results in a
-- | [`Tuple3`](https://pursuit.purescript.org/packages/purescript-tuples/docs/Data.Tuple.Nested).
-- |
-- | ```
-- | result1 /\ result2 /\ result3 <- sequential $ tuple3 <$>
-- |   do parallel
-- |       operation1
-- |   <*>
-- |   do parallel
-- |       operation2
-- |   <*>
-- |   do parallel
-- |       operation3
-- | ```
-- |
-- | #### Aff Idiom: Surprising events
-- |
-- | We have `event1`, `event2`, and `event3`, which are
-- | all side-effecting `Aff Unit` operations. We know one of them
-- | will complete next, but we don’t know which one. We want to wait for
-- | all of them at the same time.
-- |
-- | ```
-- | parOneOf
-- |   [ event1
-- |   , event2
-- |   , event3
-- |   ]
-- | ```
module Node.HTTP2
  ( HeadersObject(..)
  , toHeaders
  , sensitiveHeaders
  , headerKeys
  , headerString
  , headerArray
  , headerStatus
  , OptionsObject(..)
  , toOptions
  , Flags
  , SettingsObject(..)
  ) where

import Prelude

import Control.Monad.Except (runExcept)
import Data.Either (hush)
import Data.Maybe (Maybe, fromJust)
import Data.Newtype (class Newtype)
import Data.Traversable (traverse)
import Foreign (Foreign, readArray, readInt, readString, unsafeToForeign)
import Foreign.Index (readProp)
import Foreign.Keys (keys)
import Foreign.Object (union)
import Partial.Unsafe (unsafePartial)
import Unsafe.Coerce (unsafeCoerce)

-- | An HTTP/2 “headers object.”
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#headers-object
-- |
-- | Construct with the `toHeaders` function.
-- | The “no headers” literal is `toHeaders {}`.
-- |
-- | The `Monoid` instance allows us to merge `HeadersObject` with `<>`.
newtype HeadersObject = HeadersObject Foreign

derive instance Newtype HeadersObject _

instance Semigroup HeadersObject where
  append l r = unionHeadersImpl l r

instance Monoid HeadersObject where
  mempty = unsafeCoerce {}

foreign import unionHeadersImpl :: HeadersObject -> HeadersObject -> HeadersObject

-- | Use this function to construct a `HeadersObject` object.
-- |
-- | Rules for Headers:
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#headers-object
-- |
-- | > Headers are represented as own-properties on JavaScript objects.
-- | > The property keys will be serialized to lower-case.
-- | > Property values should be strings (if they are not they will
-- | > be coerced to strings) or an Array of strings (in order to send
-- | > more than one value per header field).
-- |
-- | This function provides no type-level enforcement of these rules.
-- |
-- | Example:
-- |
-- | ```
-- | toHeaders
-- |   { ":status": "200"
-- |   , "content-type": "text-plain"
-- |   , "ABC": ["has", "more", "than", "one", "value"]
-- |   }
-- | ```
toHeaders :: forall r. Record r -> HeadersObject
toHeaders = HeadersObject <<< unsafeToForeign

-- | Use this function to construct a “sensitive” `HeadersObject`.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#sensitive-headers
-- |
-- | Example:
-- |
-- | ```
-- | toHeaders
-- |   { "content-type": "text-plain"
-- |   }
-- | <>
-- | sensitiveHeaders
-- |   { "cookie": "some-cookie"
-- |   , "other-sensitive-header": "very secret data"
-- |   }
-- | ```
foreign import sensitiveHeaders :: forall r. Record r -> HeadersObject

-- | Get all of the keys from a `HeadersObject`.
-- |
-- | The value pointed to by each key may be either a `String`
-- | or an `Array String`.
headerKeys :: HeadersObject -> Array String
headerKeys (HeadersObject h) = unsafePartial $ fromJust $ hush $ runExcept $ keys h

-- | Try to read a `String` value from the `HeadersObject` at the given key.
headerString :: HeadersObject -> String -> Maybe String
headerString (HeadersObject h) n = hush $ runExcept do
  readString =<< readProp n h

-- | Try to read an `Array String` value from the `HeadersObject` at the given key.
headerArray :: HeadersObject -> String -> Maybe (Array String)
headerArray (HeadersObject h) n = hush $ runExcept do
  traverse readString =<< readArray =<< readProp n h

-- | https://nodejs.org/docs/latest/api/http2.html#headers-object
-- |
-- | > For incoming headers:
-- | >
-- | > * The `:status` header is converted to `number`.
headerStatus :: HeadersObject -> Maybe Int
headerStatus (HeadersObject h) = hush $ runExcept do
  readInt =<< readProp ":status" h

-- | https://httpwg.org/specs/rfc7540.html#FrameHeader
type Flags = Int

-- | A *Node.js* “options object.”
-- |
-- | Construct with the `toOptions` function, or for more type-safety
-- | use
-- | [`Data.Options.options`](https://pursuit.purescript.org/packages/purescript-options/docs/Data.Options#v:options).
-- | The “no options” literal is `toOptions {}`.
-- |
-- | The `Monoid` instance allows us to merge `OptionsObject`s with `<>`.
-- | The options
-- | in the first, left-side `OptionsObject` will override the
-- | second `OptionsObject`.
newtype OptionsObject = OptionsObject Foreign

derive instance Newtype OptionsObject _

instance Semigroup OptionsObject where
  append l r = unsafeCoerce $ union (unsafeCoerce l) (unsafeCoerce r)

instance Monoid OptionsObject where
  mempty = toOptions {}

-- | Use this function to construct an `Options`.
-- |
-- | Example:
-- |
-- | ```
-- | toOptions
-- |   { unknownProtocolTimeout: 2.0
-- |   , settings:
-- |     { maxConcurrentStreams: 100
-- |     }
-- |   , noDelay: true
-- |   , keepAliveInitialDelay: 0.5
-- |   }
-- | ```
toOptions :: forall r. Record r -> OptionsObject
toOptions = OptionsObject <<< unsafeToForeign

-- | An HTTP/2 “Settings object.”
-- |
-- | https://nodejs.org/api/http2.html#settings-object
newtype SettingsObject = SettingsObject Foreign
