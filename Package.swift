// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MKSandboxSync",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MKSandboxSync",
            targets: ["MKSandboxSync"]
        )
    ],
    targets: [
        .target(
            name: "MKSandboxSync",
            dependencies: []
        ),
        .testTarget(
            name: "MKSandboxSyncTests",
            dependencies: ["MKSandboxSync"]
        )
    ]
)
