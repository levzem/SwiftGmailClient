// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SwiftGmail",
    platforms: [
      .macOS(.v11)
    ],
    products: [
        .library(
            name: "SwiftGmail",
            targets: ["SwiftGmail"]),
    ],
    targets: [
        .target(
            name: "SwiftGmail"),
        .testTarget(
            name: "SwiftGmailTests",
            dependencies: ["SwiftGmail"]
        ),
    ]
)
