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
import Base64Swift
import WebAuthnModels
import Crypto

struct ParsedAuthenticatorAssertionResponse {
    let rawClientData: Data
    let clientData: CollectedClientData
    let rawAuthenticatorData: Data
    let authenticatorData: AuthenticatorData
    let signature: URLEncodedBase64
    let userHandle: [UInt8]?

    init(from authenticatorAssertionResponse: AuthenticatorAssertionResponse) throws {
        rawClientData = Data(authenticatorAssertionResponse.clientDataJSON)
        clientData = try JSONDecoder().decode(CollectedClientData.self, from: rawClientData)

        rawAuthenticatorData = Data(authenticatorAssertionResponse.authenticatorData)
        authenticatorData = try AuthenticatorData(bytes: rawAuthenticatorData)
        signature = authenticatorAssertionResponse.signature.base64URLEncodedString()
        userHandle = authenticatorAssertionResponse.userHandle
    }

    // swiftlint:disable:next function_parameter_count
    func verify(
        expectedChallenge: [UInt8],
        relyingPartyOrigin: String,
        relyingPartyID: String,
        requireUserVerification: Bool,
        credentialPublicKey: [UInt8],
        credentialCurrentSignCount: UInt32
    ) throws {
        try clientData.verify(
            storedChallenge: expectedChallenge,
            ceremonyType: .assert,
            relyingPartyOrigin: relyingPartyOrigin
        )

        guard let expectedRpIDData = relyingPartyID.data(using: .utf8) else {
            throw WebAuthnError.invalidRelyingPartyID
        }
        let expectedRpIDHash = SHA256.hash(data: expectedRpIDData)
        guard expectedRpIDHash == authenticatorData.relyingPartyIDHash else {
            throw WebAuthnError.relyingPartyIDHashDoesNotMatch
        }

        guard authenticatorData.flags.userPresent else { throw WebAuthnError.userPresentFlagNotSet }
        if requireUserVerification {
            guard authenticatorData.flags.userVerified else { throw WebAuthnError.userVerifiedFlagNotSet }
        }

        if authenticatorData.counter > 0 || credentialCurrentSignCount > 0 {
            guard authenticatorData.counter > credentialCurrentSignCount else {
                // This is a signal that the authenticator may be cloned, i.e. at least two copies of the credential
                // private key may exist and are being used in parallel.
                throw WebAuthnError.potentialReplayAttack
            }
        }

        let clientDataHash = SHA256.hash(data: rawClientData)
        let signatureBase = rawAuthenticatorData + clientDataHash

        let credentialPublicKey = try CredentialPublicKey(publicKeyBytes: credentialPublicKey)
        guard let signatureData = signature.urlDecoded.decoded else { throw WebAuthnError.invalidSignature }
        try credentialPublicKey.verify(signature: signatureData, data: signatureBase)
    }
}
