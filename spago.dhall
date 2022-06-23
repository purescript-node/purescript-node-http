{ name = "node-http"
, dependencies =
  [ "arraybuffer-types"
  , "contravariant"
  , "effect"
  , "foreign"
  , "foreign-object"
  , "maybe"
  , "node-buffer"
  , "node-net"
  , "node-streams"
  , "node-url"
  , "nullable"
  , "options"
  , "prelude"
  , "unsafe-coerce"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
, license = "MIT"
, repository = "https://github.com/purescript-node/purescript-node-http"
}
