import Foundation
import DatabaseKit
import NIORedis

public final class RedisDatabase {
    /// A configuration for making connections to a specific Redis server.
    public struct Configuration {
        public let hostname: String
        public let port: Int
        public let password: String?
        /// The database ID to connect to automatically.
        /// - Note: If nil, connections will default to `0`.
        public let database: Int?

        public init(
            hostname: String = "localhost",
            port: Int = 6379,
            password: String? = nil,
            database: Int? = nil
        ) {
            self.hostname = hostname
            self.port = port
            self.password = password
            self.database = database
        }

        public init?(url: URL) {
            self.hostname = url.host ?? "localhost"
            self.port = url.port ?? 6639
            self.password = url.password
            self.database = Int(url.path)
        }
    }

    public let eventLoop: EventLoop

    private let config: Configuration

    public init(config: Configuration, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.config = config
    }
}

extension RedisDatabase: Database {
    public typealias Connection = RedisConnection

    public func makeConnection() -> EventLoopFuture<RedisConnection> {
        let bootstrap = ClientBootstrap.makeForRedis(using: eventLoop)
        return bootstrap.connect(host: config.hostname, port: config.port)
            .map { return RedisConnection(channel: $0) }
            .flatMap { connection in
                guard let password = self.config.password else {
                    return self.eventLoop.makeSucceededFuture(connection)
                }

                return connection.authorize(with: password)
                    .map { _ in return connection }
            }
    }
    
    public func newConnection() -> EventLoopFuture<RedisConnection> {
        return makeConnection()
    }
}
