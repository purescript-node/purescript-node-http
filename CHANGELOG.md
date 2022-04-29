# Changelog

Notable changes to this project are documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Breaking changes:

New features:

Bugfixes:

Other improvements:

## [v8.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v8.0.0) - 2022-04-29

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#41 by @JordanMartinez, @sigma-andex)

## [v7.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v7.0.0) - 2022-04-28

Due to implementing a breaking change incorrectly, use v8.0.0 instead.

## [v6.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v6.0.0) - 2021-02-26

Breaking changes:
  - Added support for PureScript 0.14 and dropped support for all previous versions (#31)

New features:
  - Added `onUpgrade` to allow users to listen to and respond to HTTP upgrades (#33)

Other improvements:
  - Migrated CI to GitHub Actions, updated installation instructions to use Spago, and migrated from `jshint` to `eslint` (#30)
  - Added a changelog and pull request template (#34)
  
## [v5.0.2](https://github.com/purescript-node/purescript-node-http/releases/tag/v5.0.2) - 2019-07-24

- Relaxed upper bounds on `node-buffer`

## [v5.0.1](https://github.com/purescript-node/purescript-node-http/releases/tag/v5.0.1) - 2019-05-28

- Relaxed upper bounds on `foreign-object` and `options`

## [v5.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v5.0.0) - 2018-05-29

- Updated for 0.12

## [v4.2.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v4.2.0) - 2017-11-06

- Added `Node.HTTP.close` (@lpil)

## [v4.1.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v4.1.0) - 2017-08-02

- Added bindings to node's `https` module (@cprussin).

## [v4.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v4.0.0) - 2017-04-05

- Updated for 0.11 compiler (@anilanar)

## [v3.0.1](https://github.com/purescript-node/purescript-node-http/releases/tag/v3.0.1) - 2016-11-10

- Fixed an accidentally exported function (`listenImpl`).

## [v3.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v3.0.0) - 2016-11-10

- Allow specifying a hostname and backlog when calling `Node.HTTP.listen`
- Added `listenSocket`.

## [v2.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v2.0.0) - 2016-10-22

- Updated dependencies

## [v1.2.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v1.2.0) - 2016-09-06

- Added IP address family option (@kika)

## [v1.1.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v1.1.0) - 2016-08-14

- Separated headers and cookies to avoid type errors (@kika)

## [v1.0.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v1.0.0) - 2016-06-10

- Updated for 1.0/0.9.1

## [v0.4.1](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.4.1) - 2016-05-02

- Fixed license in bower.json for Pursuit

## [v0.4.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.4.0) - 2016-05-02

- Bump dependency on `purescript-node-streams`

## [v0.3.1](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.3.1) - 2016-02-28

- Added support for HTTPS (@hdgarrood)

## [v0.2.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.2.0) - 2016-01-12

- Bumped `streams` dependency (@hdgarrood)

## [v0.1.7](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.7) - 2015-11-12

- Added `setTimeout`

## [v0.1.5](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.5) - 2015-09-29

- Fixed type of `headers`.

## [v0.1.4](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.4) - 2015-09-28

- Added `requestFromURI`.

## [v0.1.3](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.3) - 2015-09-28

- Added client module.

## [v0.1.2](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.2) - 2015-09-23

- Fixed `bower.json`

## [v0.1.1](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.1) - 2015-09-23

- Deployed to Pursuit

## [v0.1.0](https://github.com/purescript-node/purescript-node-http/releases/tag/v0.1.0) - 2015-09-23

- Initial release
