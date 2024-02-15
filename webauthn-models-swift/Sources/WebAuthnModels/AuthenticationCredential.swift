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

/// The unprocessed response received from `navigator.credentials.get()`.
///
/// When decoding using `Decodable`, the `rawID` is decoded from base64url to bytes.
public struct AuthenticationCredential {
    /// The credential ID of the newly created credential.
    public let id: URLEncodedBase64

    /// The raw credential ID of the newly created credential.
    public let rawID: [UInt8]

    /// The attestation response from the authenticator.
    public let response: AuthenticatorAssertionResponse

    /// Reports the authenticator attachment modality in effect at the time the navigator.credentials.create() or
    /// navigator.credentials.get() methods successfully complete
    public let authenticatorAttachment: String?

    /// Value will always be "public-key" (for now)
    public let type: String
    
    public init(
        id: URLEncodedBase64,
        rawID: [UInt8],
        response: AuthenticatorAssertionResponse,
        authenticatorAttachment: String?,
        type: String
    ) {
        self.id = id
        self.rawID = rawID
        self.response = response
        self.authenticatorAttachment = authenticatorAttachment
        self.type = type
    }
}

extension AuthenticationCredential: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(URLEncodedBase64.self, forKey: .id)
        let rawID = try container.decodeBytesFromURLEncodedBase64(forKey: .rawID)
        let response = try container.decode(AuthenticatorAssertionResponse.self, forKey: .response)
        let authenticatorAttachment = try container.decodeIfPresent(String.self, forKey: .authenticatorAttachment)
        let type = try container.decode(String.self, forKey: .type)
        
        self.init(
            id: id,
            rawID: rawID,
            response: response,
            authenticatorAttachment: authenticatorAttachment,
            type: type
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(rawID, forKey: .rawID)
        try container.encode(response, forKey: .response)
        try container.encode(authenticatorAttachment, forKey: .authenticatorAttachment)
        try container.encode(type, forKey: .type)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case rawID = "rawId"
        case response
        case authenticatorAttachment
        case type
    }
}
