// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftGmailClient",
    platforms: [
      .macOS(.v11),
      .iOS(.v14),
    ],
    products: [
        .library(
            name: "SwiftGmailClient",
            targets: ["SwiftGmailClient"]),
    ],
    targets: [
        .target(
            name: "SwiftGmailClient"),
        .testTarget(
            name: "SwiftGmailClientTests",
            dependencies: ["SwiftGmailClient"]
        ),
    ]
)
