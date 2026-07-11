//===----------------------------------------------------------------------===//
//
// This source file is part of the WebAuthn Swift open source project
//
// Copyright (c) 2022 the WebAuthn Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of WebAuthn Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import WebAuthn
import XCTest

final class CredentialPublicKeyTests: XCTestCase {

    /// Regression: a malformed short public key whose first byte is `0x04` reaches the
    /// legacy-U2F branch. The single byte `0x04` CBOR-decodes to an integer, so it passes
    /// the CBOR guard and enters that branch; before the length guard it trapped with an
    /// index-out-of-range on `publicKeyBytes[1...33]`. It must now throw, not crash.
    func testShortU2FPublicKeyThrowsInsteadOfCrashing() {
        XCTAssertThrowsError(try CredentialPublicKey(publicKeyBytes: [0x04])) { error in
            guard case WebAuthnError.badPublicKeyBytes = error else {
                return XCTFail("expected badPublicKeyBytes, got \(error)")
            }
        }
    }
}
