// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRPCFlatbuffers",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_14),
    ],
    products: [
    ],
    dependencies: [
    // Main SwiftNIO package
    .package(path: "../flatbuffers/swift"),
    .package(url: "https://github.com/mustiikhalil/grpc-swift.git", .branch("add-ability-to-use-different-payloads"))
    ],
    targets: [
        // Model for the HelloWorld example
        .target(
          name: "Model",
          dependencies: [
            "GRPC",
            "FlatBuffers"
          ],
          path: "Sources/Model"
        ),

        // Client for the HelloWorld example
        .target(
          name: "client",
          dependencies: [
            "GRPC",
            "Model",
          ],
          path: "Sources/client"
        ),

        // Server for the HelloWorld example
        .target(
          name: "server",
          dependencies: [
            "GRPC",
            "Model",
          ],
          path: "Sources/server"
        ),

    ]
)
