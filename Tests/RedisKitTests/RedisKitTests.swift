import RedisKit
import XCTest

final class RedisKitTests: XCTestCase {
    func testVersion() throws {
        let response = try self.client.send(command: "INFO").wait()
        XCTAssert(response.string?.contains("connected_clients:1") == true, "unexpected response")
    }

    var client: RedisClient {
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
