// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "base64-swift",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Base64Swift",
            targets: ["Base64Swift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Base64Swift",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "Base64SwiftTests",
            dependencies: ["Base64Swift"]
        )
    ]
)
