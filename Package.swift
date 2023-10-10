// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "trueCaller-ios-sdk",
    platforms: [
        .iOS(.v12), // Specify the minimum iOS version
    ],
    products: [
        .library(
            name: "TrueSDK",
            targets: ["TrueSDK"]),
    ],
    targets: [
        .target(
            name: "TrueSDK",
            path: "Sources"), // Update the path to the source files of your SDK
    ]
)
