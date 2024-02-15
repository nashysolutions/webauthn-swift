import Foundation
import WebAuthnModels
import SwiftCBOR

/// A parsed version of `AuthenticatorAttestationResponse`
struct ParsedAuthenticatorAttestationResponse {
    let clientData: CollectedClientData
    let attestationObject: AttestationObject

    init(from rawResponse: AuthenticatorAttestationResponse) throws {
        // assembling clientData
        let clientData = try JSONDecoder().decode(CollectedClientData.self, from: Data(rawResponse.clientDataJSON))
        self.clientData = clientData

        // Step 11. (assembling attestationObject)
        let attestationObjectData = Data(rawResponse.attestationObject)
        guard let decodedAttestationObject = try? CBOR.decode([UInt8](attestationObjectData)) else {
            throw WebAuthnError.invalidAttestationObject
        }

        guard let authData = decodedAttestationObject["authData"],
            case let .byteString(authDataBytes) = authData else {
            throw WebAuthnError.invalidAuthData
        }
        guard let formatCBOR = decodedAttestationObject["fmt"],
            case let .utf8String(format) = formatCBOR,
            let attestationFormat = AttestationFormat(rawValue: format) else {
            throw WebAuthnError.invalidFmt
        }

        guard let attestationStatement = decodedAttestationObject["attStmt"] else {
            throw WebAuthnError.missingAttStmt
        }

        attestationObject = AttestationObject(
            authenticatorData: try AuthenticatorData(bytes: Data(authDataBytes)),
            rawAuthenticatorData: Data(authDataBytes),
            format: attestationFormat,
            attestationStatement: attestationStatement
        )
    }
}
