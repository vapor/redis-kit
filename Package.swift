// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "redis-kit",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://gitlab.com/mordil/swift-redi-stack.git", .branch("custom-logging")),
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0-beta.2"),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["AsyncKit", "RediStack", "Logging"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit", "RediStackTestUtils"]),
    ]
)
