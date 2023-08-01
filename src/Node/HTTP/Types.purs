module Node.HTTP.Types where

foreign import data OutgoingMessage :: Type

data IncomingMessageType

foreign import data IMClientRequest :: IncomingMessageType
foreign import data IMServer :: IncomingMessageType

foreign import data IncomingMessage :: IncomingMessageType -> Type

foreign import data ClientRequest :: Type

foreign import data ServerResponse :: Type

data TransmissionType

foreign import data Encrypted :: TransmissionType
foreign import data PlainText :: TransmissionType

foreign import data HttpServer' :: TransmissionType -> Type

type HttpServer = HttpServer' PlainText
type HttpsServer = HttpServer' Encrypted
