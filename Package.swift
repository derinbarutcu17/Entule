// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Entule",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Entule", targets: ["Entule"])
    ],
    targets: [
        .executableTarget(
            name: "Entule",
            path: ".",
            exclude: [
                "README.md",
                "Info.plist",
                "Resources",
                "dist",
                "scripts",
                ".build",
                "Tests"
            ]
        ),
        .testTarget(
            name: "EntuleTests",
            dependencies: ["Entule"],
            path: "Tests"
        )
    ]
)
