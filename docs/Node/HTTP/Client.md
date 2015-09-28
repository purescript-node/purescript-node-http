## Module Node.HTTP.Client

This module defines low-level bindings to the Node HTTP client.

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

#### `RequestHeaders`

``` purescript
newtype RequestHeaders
```

A HTTP request object

##### Instances
``` purescript
instance requestHeadersIsOption :: IsOption RequestHeaders
```

#### `RequestOptions`

``` purescript
data RequestOptions
```

The type of HTTP request options

#### `protocol`

``` purescript
protocol :: Option RequestOptions String
```

The protocol to use

#### `hostname`

``` purescript
hostname :: Option RequestOptions String
```

Domain name or IP

#### `port`

``` purescript
port :: Option RequestOptions Int
```

Port of remote server

#### `method`

``` purescript
method :: Option RequestOptions String
```

The HTTP request method: GET, POST, etc.

#### `path`

``` purescript
path :: Option RequestOptions String
```

The request path, including query string if appropriate.

#### `headers`

``` purescript
headers :: Option RequestOptions String
```

#### `auth`

``` purescript
auth :: Option RequestOptions String
```

Basic authentication

#### `request`

``` purescript
request :: forall eff. Options RequestOptions -> (Response -> Eff (http :: HTTP | eff) Unit) -> Eff (http :: HTTP | eff) Request
```

Make a HTTP request using the specified options and response callback.

#### `requestAsStream`

``` purescript
requestAsStream :: forall eff r a. Request -> Writable r (http :: HTTP | eff) a
```

Create a writable stream from a request object.

#### `responseAsStream`

``` purescript
responseAsStream :: forall eff w a. Response -> Readable w (http :: HTTP | eff) a
```

Create a readable stream from a response object.

#### `httpVersion`

``` purescript
httpVersion :: Response -> String
```

Get the request HTTP version

#### `responseHeaders`

``` purescript
responseHeaders :: Response -> StrMap String
```

Get the response headers as a hash


