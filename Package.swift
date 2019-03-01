// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "redis-kit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/mordil/nio-redis.git", .branch("master")),
        .package(url: "https://github.com/vapor/nio-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["NIOKit", "NIORedis"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit"]),
    ]
)
