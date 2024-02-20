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

import Foundation
import Crypto
import Base64Swift

/// This is what the authenticator device returned after we requested it to authenticate a user.
///
/// When decoding using `Decodable`, byte arrays are decoded from base64url to bytes.
public struct AuthenticatorAssertionResponse {
    /// Representation of what we passed to `navigator.credentials.get()`
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let clientDataJSON: [UInt8]

    /// Contains the authenticator data returned by the authenticator.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let authenticatorData: [UInt8]

    /// Contains the raw signature returned from the authenticator
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let signature: [UInt8]

    /// Contains the user handle returned from the authenticator, or null if the authenticator did not return
    /// a user handle. Used by to give scope to credentials.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let userHandle: [UInt8]?

    /// Contains an attestation object, if the authenticator supports attestation in assertions.
    /// The attestation object, if present, includes an attestation statement. Unlike the attestationObject
    /// in an AuthenticatorAttestationResponse, it does not contain an authData key because the authenticator
    /// data is provided directly in an AuthenticatorAssertionResponse structure.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let attestationObject: [UInt8]?
    
    public init(
        clientDataJSON: [UInt8],
        authenticatorData: [UInt8],
        signature: [UInt8],
        userHandle: [UInt8]?,
        attestationObject: [UInt8]?
    ) {
        self.clientDataJSON = clientDataJSON
        self.authenticatorData = authenticatorData
        self.signature = signature
        self.userHandle = userHandle
        self.attestationObject = attestationObject
    }
}

extension AuthenticatorAssertionResponse: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let clientDataJSON = try container.decodeBytesFromURLEncodedBase64(forKey: .clientDataJSON)
        let authenticatorData = try container.decodeBytesFromURLEncodedBase64(forKey: .authenticatorData)
        let signature = try container.decodeBytesFromURLEncodedBase64(forKey: .signature)
        let userHandle = try container.decodeBytesFromURLEncodedBase64IfPresent(forKey: .userHandle)
        let attestationObject = try container.decodeBytesFromURLEncodedBase64IfPresent(forKey: .attestationObject)
        
        self.init(
            clientDataJSON: clientDataJSON, 
            authenticatorData: authenticatorData,
            signature: signature,
            userHandle: userHandle,
            attestationObject: attestationObject
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(URLEncodedBase64(bytes: clientDataJSON), forKey: .clientDataJSON)
        try container.encode(URLEncodedBase64(bytes: authenticatorData), forKey: .authenticatorData)
        try container.encode(URLEncodedBase64(bytes: signature), forKey: .signature)
        try container.encode(URLEncodedBase64(bytes: userHandle), forKey: .userHandle)
        try container.encode(URLEncodedBase64(bytes: attestationObject), forKey: .attestationObject)
    }

    private enum CodingKeys: String, CodingKey {
        case clientDataJSON
        case authenticatorData
        case signature
        case userHandle
        case attestationObject
    }
}

private extension URLEncodedBase64 {
    
    init?(bytes: [UInt8]?) {
        guard let bytes else {
            return nil
        }
        self.init(bytes: bytes)
    }
}
