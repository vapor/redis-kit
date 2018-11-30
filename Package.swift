// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "RedisKit",
    products: [
        .library(name: "RedisKit", targets: ["RedisKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/redis.git", .branch("add-set-commands")),
    ],
    targets: [
        .target(name: "RedisKit", dependencies: ["Redis"]),
        .testTarget(name: "RedisKitTests", dependencies: ["RedisKit"]),
    ]
)
