## Module Node.HTTP

This module defines low-level bindings to the Node HTTP module.

#### `Server`

``` purescript
data Server :: *
```

The type of a HTTP server object

#### `Request`

``` purescript
data Request :: *
```

A HTTP request object

#### `Response`

``` purescript
data Response :: *
```

A HTTP response object

#### `HTTP`

``` purescript
data HTTP :: !
```

The effect associated with using the HTTP module.

#### `createServer`

``` purescript
createServer :: forall eff. (Request -> Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Server
```

Create a HTTP server, given a function to be executed when a request is received.

#### `listen`

``` purescript
listen :: forall eff. Server -> Int -> Eff (http :: HTTP | eff) Unit -> Eff (http :: HTTP | eff) Unit
```

Listen on the specified port. The specified callback will be run when setup is complete.

#### `httpVersion`

``` purescript
httpVersion :: Request -> String
```

Get the request HTTP version

#### `requestHeaders`

``` purescript
requestHeaders :: Request -> StrMap String
```

Get the request headers as a hash

#### `requestMethod`

``` purescript
requestMethod :: Request -> String
```

Get the request method (GET, POST, etc.)

#### `requestURL`

``` purescript
requestURL :: Request -> String
```

Get the request URL

#### `requestAsStream`

``` purescript
requestAsStream :: forall eff a. Request -> Readable () (http :: HTTP | eff) a
```

Coerce the request object into a readable stream.

#### `setHeader`

``` purescript
setHeader :: forall eff. Response -> String -> String -> Eff (http :: HTTP | eff) Unit
```

Set a header with a single value.

#### `setHeaders`

``` purescript
setHeaders :: forall eff. Response -> String -> Array String -> Eff (http :: HTTP | eff) Unit
```

Set a header with multiple values.

#### `setStatusCode`

``` purescript
setStatusCode :: forall eff. Response -> Int -> Eff (http :: HTTP | eff) Unit
```

Set the status code.

#### `setStatusMessage`

``` purescript
setStatusMessage :: forall eff. Response -> String -> Eff (http :: HTTP | eff) Unit
```

Set the status message.

#### `responseAsStream`

``` purescript
responseAsStream :: forall eff a. Response -> Writable () (http :: HTTP | eff) a
```

Coerce the response object into a writable stream.


