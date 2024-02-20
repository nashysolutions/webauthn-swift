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
import Base64Swift

/// The unprocessed response received from `navigator.credentials.create()`.
///
/// When decoding using `Decodable`, the `rawID` is decoded from base64url to bytes.
public struct RegistrationCredential {
    /// The credential ID of the newly created credential.
    public let id: URLEncodedBase64

    /// Value will always be "public-key" (for now)
    public let type: String

    /// The raw credential ID of the newly created credential.
    public let rawID: [UInt8]

    /// The attestation response from the authenticator.
    public let attestationResponse: AuthenticatorAttestationResponse
    
    public init(
        id: URLEncodedBase64,
        type: String,
        rawID: [UInt8],
        attestationResponse: AuthenticatorAttestationResponse
    ) {
        self.id = id
        self.type = type
        self.rawID = rawID
        self.attestationResponse = attestationResponse
    }
}

extension RegistrationCredential: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(URLEncodedBase64.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        
        guard let rawID = try container.decode(URLEncodedBase64.self, forKey: .rawID).decodedBytes else {
            throw DecodingError.dataCorruptedError(
                forKey: .rawID,
                in: container,
                debugDescription: "Failed to decode base64url encoded rawID into bytes"
            )
        }
        
        let attestationResponse = try container.decode(AuthenticatorAttestationResponse.self, forKey: .attestationResponse)
        self.init(id: id, type: type, rawID: rawID, attestationResponse: attestationResponse)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(URLEncodedBase64(bytes: rawID), forKey: .rawID)
        try container.encode(attestationResponse, forKey: .attestationResponse)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case rawID = "rawId"
        case attestationResponse = "response"
    }
}

/// The response from the authenticator device for the creation of a new public key credential.
///
/// When decoding using `Decodable`, `clientDataJSON` and `attestationObject` are decoded from base64url to bytes.
public struct AuthenticatorAttestationResponse {
    /// The client data that was passed to the authenticator during the creation ceremony.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let clientDataJSON: [UInt8]

    /// Contains both attestation data and attestation statement.
    ///
    /// When decoding using `Decodable`, this is decoded from base64url to bytes.
    public let attestationObject: [UInt8]
    
    public init(clientDataJSON: [UInt8], attestationObject: [UInt8]) {
        self.clientDataJSON = clientDataJSON
        self.attestationObject = attestationObject
    }
}

extension AuthenticatorAttestationResponse: Codable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let clientDataJSON = try container.decodeBytesFromURLEncodedBase64(forKey: .clientDataJSON)
        let attestationObject = try container.decodeBytesFromURLEncodedBase64(forKey: .attestationObject)
        self.init(clientDataJSON: clientDataJSON, attestationObject: attestationObject)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(URLEncodedBase64(bytes: clientDataJSON), forKey: .clientDataJSON)
        try container.encode(URLEncodedBase64(bytes: attestationObject), forKey: .attestationObject)
    }

    private enum CodingKeys: String, CodingKey {
        case clientDataJSON
        case attestationObject
    }
}
