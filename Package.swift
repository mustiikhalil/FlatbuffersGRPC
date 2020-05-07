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
        .package(url: "https://github.com/mustiikhalil/flatbuffers.git", from: "0.4.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0-alpha.11")
    ],
    targets: [
        .target(
            name: "FLATHelloWorldModel",
            dependencies: [
                "GRPC",
                "FlatBuffers"
            ],
            path: "Sources/HelloWorld/Model"
        ),
        
        // Client for the HelloWorld example
        .target(
            name: "FLATHelloWorldClient",
            dependencies: [
                "GRPC",
                "FLATHelloWorldModel",
            ],
            path: "Sources/HelloWorld/Client"
        ),
        
        // Server for the HelloWorld example
        .target(
            name: "FLATHelloWorldServer",
            dependencies: [
                "GRPC",
                "FLATHelloWorldModel",
            ],
            path: "Sources/HelloWorld/Server"
        ),
        
        .target(
            name: "FLATRouteGuideModel",
            dependencies: [
                "GRPC",
                "FlatBuffers"
            ],
            path: "Sources/RouteGuide/Model"
        ),
        
        .target(
            name: "FLATRouteGuideClient",
            dependencies: [
                "GRPC",
                "FLATRouteGuideModel",
            ],
            path: "Sources/RouteGuide/Client"
        ),
        
        .target(
            name: "FLATRouteGuideServer",
            dependencies: [
                "GRPC",
                "FLATRouteGuideModel",
            ],
            path: "Sources/RouteGuide/Server"
        )
    ]
)
