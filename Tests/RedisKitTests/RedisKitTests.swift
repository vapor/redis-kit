import RedisKit
import XCTest

final class RedisKitTests: XCTestCase {
    var connectionPool: EventLoopGroupConnectionPool<RedisConnectionSource>!
    var eventLoopGroup: EventLoopGroup!

    override func setUp() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let source = RedisConnectionSource(configuration: .init(
            hostname: ProcessInfo.processInfo.environment["REDIS_HOSTNAME"] ?? "localhost",
            port: 6379,
            password: nil,
            database: nil,
            logger: nil
        ))
        self.connectionPool = .init(source: source, on: self.eventLoopGroup)
    }

    override func tearDown() {
        try! self.eventLoopGroup.syncShutdownGracefully()
    }
  
    private func client() throws -> RediStack.RedisClient {
        return try self.connectionPool.pool(for: self.eventLoopGroup.next()).requestConnection().wait()
    }
  
    func testVersion() throws {
        let response = try self.client().send(command: "INFO").wait()
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
        let hello = Hello(message: "world", array: [1, 2, 3], dict: ["yes": true, "no": false])
        try self.client().set("hello", toJSON: hello).wait()
        let get = try self.client().get("hello", asJSON: Hello.self).wait()
        XCTAssertEqual(get?.message, "world")
        XCTAssertEqual(get?.array.first, 1)
        XCTAssertEqual(get?.array.last, 3)
        XCTAssertEqual(get?.dict["yes"], true)
        XCTAssertEqual(get?.dict["false"], false)
        let _ = try self.client().delete(["hello"]).wait()
    }
}
