// swift-tools-version:5.7
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

import PackageDescription

let package = Package(
    name: "webauthn-swift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "WebAuthn", targets: ["WebAuthn"])
    ],
    dependencies: [
        .package(url: "https://github.com/unrelentingtech/SwiftCBOR.git", from: "0.4.5"),
        .package(url: "https://github.com/apple/swift-crypto.git", "2.0.0" ..< "4.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/nashysolutions/webauthn-swift-models.git", .upToNextMinor(from: "2.0.0")),
        .package(url: "https://github.com/nashysolutions/base64-swift.git", .upToNextMinor(from: "1.1.0"))
    ],
    targets: [
        .target(
            name: "WebAuthn",
            dependencies: [
                "SwiftCBOR",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "WebAuthnModels", package: "webauthn-swift-models"),
                .product(name: "Base64Swift", package: "base64-swift")
            ]
        ),
        .testTarget(name: "WebAuthnTests",
                    dependencies: [
                        .target(name: "WebAuthn"),
                        .product(name: "WebAuthnModels", package: "webauthn-swift-models")
        ])
    ]
)
