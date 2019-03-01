// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "redis-kit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/tanner0101/nio-redis.git", .branch("nio2-ctx-fixes")),
        .package(url: "https://github.com/vapor/nio-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["NIOKit", "NIORedis"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit"]),
    ]
)
