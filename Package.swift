// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DealZoxAdmin",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "DealZoxAdmin",
            targets: ["DealZoxAdmin"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DealZoxAdmin",
            dependencies: []
        ),
    ]
)
