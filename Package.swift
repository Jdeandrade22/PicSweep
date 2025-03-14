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
        // Add any dependencies here if needed
    ],
    targets: [
        .target(
            name: "PicSweep",
            dependencies: []),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"]),
    ]
) 