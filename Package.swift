// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PicSweep",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "PicSweep",
            targets: ["PicSweep"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "0.0.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "PicSweep",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Resources")
            ]),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"]),
    ]
) 