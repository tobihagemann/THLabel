// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "THLabel",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "THLabel",
            targets: ["THLabel"]),
    ],
    targets: [
        .target(
            name: "THLabel",
            dependencies: []),
        .testTarget(
            name: "THLabelTests",
            dependencies: ["THLabel"]),
    ]
)
