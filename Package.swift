// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Watcher",
    dependencies: [
        .package(url: "https://github.com/kiliankoe/CLISpinner", from: "0.3.4")
    ],
    targets: [
        .target(
            name: "Watcher",
            dependencies: ["CLISpinner"]),
        .testTarget(
            name: "WatcherTests",
            dependencies: ["Watcher"]),
    ]
)
