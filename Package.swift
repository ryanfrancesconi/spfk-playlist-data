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
        .package(url: "https://github.com/ryanfrancesconi/spfk-audio-base", from: "1.0.1"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-metadata-base", from: "1.0.2"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-search", from: "1.0.0"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-utils", from: "1.0.2"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "SPFKPlaylistData",
            dependencies: [
                .product(name: "SPFKAudioBase", package: "spfk-audio-base"),
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
