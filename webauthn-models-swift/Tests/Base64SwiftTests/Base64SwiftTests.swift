import XCTest
@testable import Base64Swift

final class Base64SwiftTests: XCTestCase {
    
    func testBase64URLEncodeReturnsCorrectString() {
        let input: [UInt8] = [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 0, 0, 1, 0]
        let expectedBase64 = "AQABAAEBAAEAAQEAAAABAA=="
        let expectedBase64URL = "AQABAAEBAAEAAQEAAAABAA"

        let base64Encoded = EncodedBase64(bytes: input)
        let base64URLEncoded = URLEncodedBase64(base64: base64Encoded)

        XCTAssertEqual(expectedBase64, base64Encoded.value)
        XCTAssertEqual(expectedBase64URL, base64URLEncoded.value)
        XCTAssertEqual(base64URLEncoded.urlDecoded, base64Encoded)
        XCTAssertEqual(base64Encoded.urlEncoded, base64URLEncoded)
    }

    func testEncodeBase64Codable() throws {
        let base64: EncodedBase64 = "AQABAAEBAAEAAQEAAAABAA=="
        let json = try JSONEncoder().encode(base64)
        let decodedBase64 = try JSONDecoder().decode(EncodedBase64.self, from: json)
        XCTAssertEqual(base64, decodedBase64)
    }
}
