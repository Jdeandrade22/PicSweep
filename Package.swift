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
        .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "PicSweep",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ],
            resources: [
                .process("Assets.xcassets")
            ]),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"]),
    ]
) 