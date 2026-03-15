// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-playlist-data",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "SPFKPlaylistData",
            targets: ["SPFKPlaylistData"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-metadata-base", from: "0.0.1"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-search", from: "0.0.5"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-utils", from: "0.0.8"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "0.0.9"),
    ],
    targets: [
        .target(
            name: "SPFKPlaylistData",
            dependencies: [
                .product(name: "SPFKMetadataBase", package: "spfk-metadata-base"),
                .product(name: "SPFKSearch", package: "spfk-search"),
                .product(name: "SPFKUtils", package: "spfk-utils"),
            ]
        ),
        .testTarget(
            name: "SPFKPlaylistDataTests",
            dependencies: [
                "SPFKPlaylistData",
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ]
)
