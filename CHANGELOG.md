# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-11

First release.

### Changed

- Public models (options, credentials, responses, and related request/response
  types) are now provided by the [`webauthn-swift-models`](https://github.com/nashysolutions/webauthn-swift-models)
  dependency instead of living directly in this package.
- Base64 and Base64URL encoding/decoding is now provided by the
  [`base64-swift`](https://github.com/nashysolutions/base64-swift) dependency.
- Widened the `swift-crypto` dependency floor to allow `3.x` releases
  (`"2.0.0" ..< "4.0.0"`).
- Raised the `swift-certificates` dependency floor to `1.0.0`.
- Raised the minimum supported platform to macOS 13.
