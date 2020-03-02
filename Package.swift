// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "redis-kit",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://gitlab.com/mordil/swift-redi-stack.git", from: "1.0.0-alpha.7"),
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0-rc"),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: [
            .product(name: "AsyncKit", package: "async-kit"),
            .product(name: "RediStack", package: "swift-redi-stack"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "RedisKitTests", dependencies: [
            .target(name: "RedisKit"),
            .product(name: "RediStackTestUtils", package: "swift-redi-stack"),
        ]),
    ]
)
