import RedisKit
import XCTest

final class RedisKitTests: XCTestCase {
    func testVersion() throws {
        let response = try self.client.send(command: "INFO").wait()
        XCTAssert(response.string?.contains("connected_clients:1") == true, "unexpected response")
    }

    func testIsClosed() throws {
        let _: Void = try self.connectionPool.withConnection { connection in
            XCTAssertEqual(connection.isClosed, false)
            return connection.eventLoop.makeSucceededFuture(())
        }.wait()
    }

    func testStruct() throws {
        struct Hello: Codable {
            var message: String
            var array: [Int]
            var dict: [String: Bool]
        }
        let hello = Hello(message: "world", array: [1, 2, 3], dict: ["yes": true, "false": false])
        try self.client.jsonSet("hello", to: hello).wait()
        let get = try self.client.jsonGet("hello", as: Hello.self).wait()
        XCTAssertEqual(get?.message, "world")
        XCTAssertEqual(get?.array.first, 1)
        XCTAssertEqual(get?.array.last, 3)
        XCTAssertEqual(get?.dict["yes"], true)
        XCTAssertEqual(get?.dict["false"], false)
        let _ = try self.client.delete(["hello"]).wait()
    }

    var client: RediStack.RedisClient {
        return self.connectionPool
    }

    var connectionPool: ConnectionPool<RedisConnectionSource>!
    var eventLoopGroup: EventLoopGroup!

    override func setUp() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

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
        ), eventLoop: self.eventLoopGroup.next())
        self.connectionPool = .init(config: .init(maxConnections: 4), source: source)
    }

    override func tearDown() {
        try! self.eventLoopGroup.syncShutdownGracefully()
    }
}
