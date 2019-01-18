// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "RedisKit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/database-kit.git", .branch("2")),
        .package(url: "https://github.com/mordil/nio-redis.git", .branch("master"))
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["NIORedis", "DatabaseKit"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit"]),
    ]
)
