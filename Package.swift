// swift-tools-version:5.8
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
                .define("RELEASE", .when(configuration: .release))
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