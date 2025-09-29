// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LaserDetectorPackage",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "LaserDetector",
            targets: ["LaserDetector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "LaserDetector",
            dependencies: []),
        .testTarget(
            name: "LaserDetectorTests",
            dependencies: ["LaserDetector"]),
    ]
)
