// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TimeConverter",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "TimeConverter", targets: ["TimeConverter"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "TimeConverter",
            dependencies: ["HotKey"],
            path: "Sources/TimeConverter"
        )
    ]
) 