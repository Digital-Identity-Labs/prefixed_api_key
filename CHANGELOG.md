# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2025-03-23
A patch update to fix a missing secure compare in `verify?/3`

### Fixes
- Secure compare is now also used for comparison in `verify?/3` - thanks to @stillwondering

### Changed
- Development dependencies have been updated slightly

## [0.2.1] - 2023-10-16
A patch update to fix dependency issues. 

### Changed
- PUID library has been updated to require at least version 2.2 (thanks to @Rodeoclash for the nudge) - fixes issue #1.

## [0.2.0] - 2022-06-10
Minor change to improve key verification by using a secure compare function

### Added
- Secure Compare function to defend against key guessing using timing attacks, borrowed from
  [Plug Crypto](https://github.com/elixir-plug/plug_crypto)

## [0.1.0] - 2022-06-01
Initial release

[0.2.2]: https://github.com/Digital-Identity-Labs/prefixed_api_key/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/Digital-Identity-Labs/prefixed_api_key/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/Digital-Identity-Labs/prefixed_api_key/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/Digital-Identity-Labs/prefixed_api_key/compare/releases/tag/0.1.0
