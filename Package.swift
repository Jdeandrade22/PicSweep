// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "PicSweep",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)  // Added for CI build support
    ],
    products: [
        .library(
            name: "PicSweep",
            targets: ["PicSweep"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
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
                .define("DISABLE_ARKIT", .when(platforms: [.macOS]))  // Fixed syntax for platform condition
            ]
        ),
        .testTarget(
            name: "PicSweepTests",
            dependencies: ["PicSweep"],
            path: "Tests/PicSweepTests",
            swiftSettings: [
                .define("TESTING", .when(configuration: .debug)),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency"),
                .define("DISABLE_ARKIT", .when(platforms: [.macOS]))  // Fixed syntax for platform condition
            ]
        ),
    ]
) 