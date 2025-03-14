// swift-tools-version:5.8
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
        .package(url: "https://github.com/apple/swift-log.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "PicSweep",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [
                .process("Assets.xcassets")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
            ]
        ),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"],
            path: "Tests/PicSweepTests",
            swiftSettings: [
                .define("TESTING", .when(configuration: .debug)),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
) 