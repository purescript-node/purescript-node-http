-- Spago configuration for testing.

let conf = ./spago.dhall

in conf //
{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, dependencies = conf.dependencies #
  [ "aff"
  , "console"
  , "either"
  , "exceptions"
  , "foldable-traversable"
  , "node-process"
  , "parallel"
  , "partial"
  , "spec"
  , "tuples"
  ]
}
