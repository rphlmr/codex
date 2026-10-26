// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CodexUsage",
    platforms: [.macOS(.v26)],
    products: [.executable(name: "CodexUsage", targets: ["CodexUsage"])],
    targets: [
        .target(name: "UsageCore"),
        .executableTarget(name: "CodexUsage", dependencies: ["UsageCore"]),
        .testTarget(name: "UsageCoreTests", dependencies: ["UsageCore"]),
    ]
)
