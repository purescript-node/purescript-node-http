-- Spago configuration for testing.

let conf = ./spago.dhall

in conf //
{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, dependencies = conf.dependencies #
	[ "console"
  , "node-process"
  , "st"
  , "spec"
  , "strings"
  , "tuples"
  ]
}
