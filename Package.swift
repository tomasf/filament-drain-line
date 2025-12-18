// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "model",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/tomasf/Helical.git", from: "0.4.1")
    ],
    targets: [
        .executableTarget(
            name: "model",
            dependencies: ["Cadova", "Helical"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ]
)
