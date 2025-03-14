// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PicSweep",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PicSweep",
            targets: ["PicSweep"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "PicSweep",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"]),
    ]
) 