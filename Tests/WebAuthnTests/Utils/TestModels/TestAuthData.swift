//===----------------------------------------------------------------------===//
//
// This source file is part of the WebAuthn Swift open source project
//
// Copyright (c) 2023 the WebAuthn Swift project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of WebAuthn Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Foundation
import Crypto
import WebAuthn

struct TestAuthData {
    var rpIDHash: [UInt8]?
    var flags: UInt8?
    var counter: [UInt8]?
    var attestedCredData: [UInt8]?
    var extensions: [UInt8]?

    var byteArrayRepresentation: [UInt8] {
        var value: [UInt8] = []
        if let rpIDHash {
            value += rpIDHash
        }
        if let flags {
            value += [flags]
        }
        if let counter {
            value += counter
        }
        if let attestedCredData {
            value += attestedCredData
        }
        if let extensions {
            value += extensions
        }
        return value
    }
}

struct TestAuthDataBuilder {
    private var wrapped: TestAuthData

    init(wrapped: TestAuthData = TestAuthData()) {
        self.wrapped = wrapped
    }

    func build() -> TestAuthData {
        wrapped
    }

    func buildAsBase64URLEncoded() -> URLEncodedBase64 {
        build().byteArrayRepresentation.base64URLEncodedString()
    }

    func validMock() -> Self {
        self
            .rpIDHash(fromRpID: "example.com")
            .flags(0b01000101)
            .counter([0b00000000, 0b00000000, 0b00000000, 0b00000000])
            .attestedCredData(
                aaguid: [UInt8](repeating: 0, count: 16),
                credentialIDLength: [0b00000000, 0b00000001],
                credentialID: [0b00000001],
                credentialPublicKey: TestCredentialPublicKeyBuilder().validMock().buildAsByteArray()
            )
            .extensions([UInt8](repeating: 0, count: 20))
    }

    /// Creates a valid authData
    ///
    /// rpID = "example.com", user
    /// flags "extension data included", "user verified" and "user present" are set
    /// sign count is set to 0
    /// random extension data is included
    func validAuthenticationMock() -> Self {
        self
            .rpIDHash(fromRpID: "example.com")
            .flags(0b10000101)
            .counter([0b00000000, 0b00000000, 0b00000000, 0b00000000])
            .extensions([UInt8](repeating: 0, count: 20))
    }

    func rpIDHash(fromRpID rpID: String) -> Self {
        let rpIDData = rpID.data(using: .utf8)!
        let rpIDHash = SHA256.hash(data: rpIDData)
        var temp = self
        temp.wrapped.rpIDHash = [UInt8](rpIDHash)
        return temp
    }

    ///           ED AT __ BS BE UV __ UP
    /// e.g.: 0b  0  1  0  0  0  0  0  1
    func flags(_ byte: UInt8) -> Self {
        var temp = self
        temp.wrapped.flags = byte
        return temp
    }

    /// A valid counter has length 4
    func counter(_ counter: [UInt8]) -> Self {
        var temp = self
        temp.wrapped.counter = counter
        return temp
    }

    /// aaguid length = 16
    /// credentialIDLength length = 2
    /// credentialID length = credentialIDLength
    /// credentialPublicKey = variable
    func attestedCredData(
        aaguid: [UInt8] = [UInt8](repeating: 0, count: 16),
        credentialIDLength: [UInt8] = [0b00000000, 0b00000001],
        credentialID: [UInt8] = [0b00000001],
        credentialPublicKey: [UInt8]
    ) -> Self {
        var temp = self
        temp.wrapped.attestedCredData = aaguid + credentialIDLength + credentialID + credentialPublicKey
        return temp
    }

    func noAttestedCredentialData() -> Self {
        var temp = self
        temp.wrapped.attestedCredData = nil
        return temp
    }

    func extensions(_ extensions: [UInt8]) -> Self {
        var temp = self
        temp.wrapped.extensions = extensions
        return temp
    }

    func noExtensionData() -> Self {
        var temp = self
        temp.wrapped.extensions = nil
        return temp
    }
}

extension TestAuthData {
    static var valid: Self {
        TestAuthData(
            rpIDHash: [1],
            flags: 1,
            counter: [1],
            attestedCredData: [2],
            extensions: [1]
        )
    }
}
