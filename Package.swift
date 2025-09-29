// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LaserDetector",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .app(
            name: "LaserDetector",
            targets: ["LaserDetector"]
        )
    ],
    targets: [
        .target(
            name: "LaserDetector",
            path: "Sources/LaserDetector"
        ),
        .testTarget(
            name: "LaserDetectorTests",
            dependencies: ["LaserDetector"],
            path: "Tests/LaserDetectorTests",
            sources: ["LaserDetectorTests.swift"]
        )
    ]
)
