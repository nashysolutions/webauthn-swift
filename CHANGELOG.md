# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-07-11

### Fixed

- Harden legacy-U2F public-key parsing in `CredentialPublicKey`. A malformed
  short public key beginning with `0x04` (attacker-influenced during a
  registration ceremony) previously trapped with an index-out-of-range crash;
  it now throws `WebAuthnError.badPublicKeyBytes`. The fix also corrects the
  coordinate extraction to the proper 32-byte halves of an uncompressed P-256
  point — the previous 33-byte overlapping ranges required 66 bytes and would
  also have crashed a valid 65-byte key.

### Removed

- The `swift-certificates` dependency (and its `X509` product). It was declared
  but never used by any compiled code — the packed-attestation path that would
  need it is unimplemented (commented-out WIP), so consumers no longer resolve
  `swift-certificates` / `swift-asn1` transitively. It will return alongside a
  future packed-attestation implementation. No public API change: the
  `pemRootCertificatesByFormat: [AttestationFormat: [Data]]` parameter is
  `Data`-typed and is unaffected.

### Documentation

- Clarified on `Credential.id` that it is **standard** Base64 while
  `VerifiedAuthentication.credentialID` is Base64URL, so relying parties can
  reconcile the two when keying credential storage.

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
