// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "redis-kit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .branch("master")),
        .package(url: "https://github.com/mordil/nio-redis.git", .revision("remove-driver")),
        .package(url: "https://github.com/vapor/nio-kit.git", .branch("master")),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["NIOKit", "NIORedis", "Logging"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit"]),
    ]
)
