// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "redis-kit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://gitlab.com/mordil/swift-redi-stack.git", from: "1.0.0-alpha.5"),
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0-beta"),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["AsyncKit", "RediStack", "Logging"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit", "RediStackTestUtils"]),
    ]
)
