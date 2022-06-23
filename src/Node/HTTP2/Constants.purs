-- | # `http2.constants`
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#http2constants
module Node.HTTP2.Constants where

import Data.Maybe (Maybe(..))

-- | Error codes for `RST_STREAM` and `GOAWAY`.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#http2constants
type NGHTTP2 = Int

-- | Get the Constant string for an NGHTTP2 error code.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#error-codes-for-rst_stream-and-goaway
ngHTTP2_String :: NGHTTP2 -> Maybe String
ngHTTP2_String 0 = Just "NGHTTP2_NO_ERROR"
ngHTTP2_String 1 = Just "NGHTTP2_PROTOCOL_ERROR"
ngHTTP2_String 2 = Just "NGHTTP2_INTERNAL_ERROR"
ngHTTP2_String 3 = Just "NGHTTP2_FLOW_CONTROL_ERROR"
ngHTTP2_String 4 = Just "NGHTTP2_SETTINGS_TIMEOUT"
ngHTTP2_String 5 = Just "NGHTTP2_STREAM_CLOSED"
ngHTTP2_String 6 = Just "NGHTTP2_FRAME_SIZE_ERROR"
ngHTTP2_String 7 = Just "NGHTTP2_REFUSED_STREAM"
ngHTTP2_String 8 = Just "NGHTTP2_CANCEL"
ngHTTP2_String 9 = Just "NGHTTP2_COMPRESSION_ERROR"
ngHTTP2_String 10 = Just "NGHTTP2_CONNECT_ERROR"
ngHTTP2_String 11 = Just "NGHTTP2_ENHANCE_YOUR_CALM"
ngHTTP2_String 12 = Just "NGHTTP2_INADEQUATE_SECURITY"
ngHTTP2_String 13 = Just "NGHTTP2_HTTP_1_1_REQUIRED"
ngHTTP2_String _ = Nothing

-- | Get the Name for an NGHTTP2 error code.
-- |
-- | https://nodejs.org/docs/latest/api/http2.html#error-codes-for-rst_stream-and-goaway
ngHTTP2_Name :: NGHTTP2 -> Maybe String
ngHTTP2_Name 0 = Just "No Error"
ngHTTP2_Name 1 = Just "Protocol Error"
ngHTTP2_Name 2 = Just "Internal Error"
ngHTTP2_Name 3 = Just "Flow Control Error"
ngHTTP2_Name 4 = Just "Settings Timeout"
ngHTTP2_Name 5 = Just "Stream Closed"
ngHTTP2_Name 6 = Just "Frame Size Error"
ngHTTP2_Name 7 = Just "Refused Stream"
ngHTTP2_Name 8 = Just "Cancel"
ngHTTP2_Name 9 = Just "Compression Error"
ngHTTP2_Name 10 = Just "Connect Error"
ngHTTP2_Name 11 = Just "Enhance Your Calm"
ngHTTP2_Name 12 = Just "Inadequate Security"
ngHTTP2_Name 13 = Just "HTTP/1.1 Required"
ngHTTP2_Name _ = Nothing

ngHTTP2_NO_ERROR = 0 :: NGHTTP2
ngHTTP2_PROTOCOL_ERROR = 1 :: NGHTTP2
ngHTTP2_INTERNAL_ERROR = 2 :: NGHTTP2
ngHTTP2_FLOW_CONTROL_ERROR = 3 :: NGHTTP2
ngHTTP2_SETTINGS_TIMEOUT = 4 :: NGHTTP2
ngHTTP2_STREAM_CLOSED = 5 :: NGHTTP2
ngHTTP2_FRAME_SIZE_ERROR = 6 :: NGHTTP2
ngHTTP2_REFUSED_STREAM = 7 :: NGHTTP2
ngHTTP2_CANCEL = 8 :: NGHTTP2
ngHTTP2_COMPRESSION_ERROR = 9 :: NGHTTP2
ngHTTP2_CONNECT_ERROR = 10 :: NGHTTP2
ngHTTP2_ENHANCE_YOUR_CALM = 11 :: NGHTTP2
ngHTTP2_INADEQUATE_SECURITY = 12 :: NGHTTP2
ngHTTP2_HTTP_1_1_REQUIRED = 13 :: NGHTTP2
