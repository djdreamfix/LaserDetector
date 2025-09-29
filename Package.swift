// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyAwesomePackage",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "MyAwesomeLibrary",
            targets: ["MyAwesomeLibrary"]),
        .executable(
            name: "MyAwesomeTool",
            targets: ["MyAwesomeTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "MyAwesomeLibrary",
            dependencies: []),
        .executableTarget(
            name: "MyAwesomeTool",
            dependencies: ["MyAwesomeLibrary", .product(name: "ArgumentParser", package: "swift-argument-parser")]),
        .testTarget(
            name: "MyAwesomeLibraryTests",
            dependencies: ["MyAwesomeLibrary"]),
    ]
)
