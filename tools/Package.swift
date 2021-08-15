// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", .branch("swift-5.4-branch")),
        // .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMajor(from: "0.43.1"))
    ]
)
