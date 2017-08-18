// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Watcher",
    dependencies: [
//        .package(url: "https://github.com/krzysztofzablocki/KZFileWatchers.git", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: "WatcherExecutable",
            dependencies: ["FileWatcher"]),
        .target(
            name: "FileWatcher",
            dependencies: []),
        .testTarget(
            name: "WatcherTests",
            dependencies: ["FileWatcher"]),
    ]
)
