import RedisKit
import RediStackTestUtils
import XCTest

final class RedisDatabaseTests: XCTestCase {
    func testConnection() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let hostname: String
        #if os(Linux)
        hostname = "redis"
        #else
        hostname = "localhost"
        #endif

        let source = RedisConnectionSource(config: .init(
            hostname: hostname,
            port: 6379,
            password: nil,
            database: nil,
            logger: nil
        ), eventLoop: eventLoopGroup.next())
        let client: RediStack.RedisClient = ConnectionPool<RedisConnectionSource>(config: .init(maxConnections: 4), source: source)

        try client.set("hello", to: "world").wait()
        let get = try client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")
        let _ = try client.delete(["hello"]).wait()
        XCTAssertNil(try client.get("hello", as: String.self).wait())

        try! eventLoopGroup.syncShutdownGracefully()
    }

    func testSelect() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let hostname: String
        #if os(Linux)
        hostname = "redis"
        #else
        hostname = "localhost"
        #endif

        let source = RedisConnectionSource(config: .init(
            hostname: hostname,
            port: 6379,
            password: nil,
            database: nil,
            logger: nil
        ), eventLoop: eventLoopGroup.next())
        let client: RediStack.RedisClient = ConnectionPool<RedisConnectionSource>(config: .init(maxConnections: 4), source: source)

        let _ = try client.select(database: 2).wait()
        try client.set("hello", to: "world").wait()
        let get = try client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")

        let _ = try client.select(database: 0).wait()
        XCTAssertNil(try client.get("hello", as: String.self).wait())

        let _ = try client.select(database: 2).wait()
        let reget = try client.get("hello", as: String.self).wait()
        XCTAssertEqual(reget, "world")

        let _ = try client.delete(["hello"]).wait()
        XCTAssertNil(try client.get("hello", as: String.self).wait())

        try! eventLoopGroup.syncShutdownGracefully()
    }

    func testSelectViaConfig() throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let hostname: String
        #if os(Linux)
        hostname = "redis"
        #else
        hostname = "localhost"
        #endif

        let source = RedisConnectionSource(config: .init(
            hostname: hostname,
            port: 6379,
            password: nil,
            database: 2,
            logger: nil
        ), eventLoop: eventLoopGroup.next())
        let client: RediStack.RedisClient = ConnectionPool<RedisConnectionSource>(config: .init(maxConnections: 4), source: source)

        try client.set("hello", to: "world").wait()
        let get = try client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")

        let _ = try client.select(database: 0).wait()
        XCTAssertNil(try client.get("hello", as: String.self).wait())

        let _ = try client.select(database: 2).wait()
        let reget = try client.get("hello", as: String.self).wait()
        XCTAssertEqual(reget, "hello")

        let _ = try client.delete(["hello"]).wait()
        XCTAssertNil(try client.get("hello", as: String.self).wait())

        try! eventLoopGroup.syncShutdownGracefully()
    }
}
