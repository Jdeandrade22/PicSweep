// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "PicSweep",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)  // Added for CI build support
    ],
    products: [
        .executable(
            name: "PicSweep",
            targets: ["PicSweep"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PicSweep",
            dependencies: [],
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