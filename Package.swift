// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PicSweep",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PicSweep",
            targets: ["PicSweep"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PicSweep",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"],
            path: "Tests")
    ]
) 