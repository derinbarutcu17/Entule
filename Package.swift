// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "WorkCheckpoint",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "WorkCheckpoint", targets: ["WorkCheckpoint"])
    ],
    targets: [
        .executableTarget(
            name: "WorkCheckpoint",
            path: ".",
            exclude: [
                "Tests",
                "README.md",
                "Info.plist"
            ]
        ),
        .testTarget(
            name: "WorkCheckpointTests",
            dependencies: ["WorkCheckpoint"],
            path: "Tests"
        )
    ]
)
