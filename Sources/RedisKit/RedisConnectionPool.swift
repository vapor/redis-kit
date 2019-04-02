import NIOKit
import NIORedis

extension RedisConnection: ConnectionPoolItem {
    /// See `ConnectionPoolItem.isClosed`
    public var isClosed: Bool { return self.isConnected }
}

extension ConnectionPool: RedisClient where Source.Connection: RedisConnection {
    /// See `RedisClient.eventLoop`
    public var eventLoop: EventLoop { return self.source.eventLoop }

    /// Sources a connection and forwards the command to the `RedisClient` instance.
    ///
    /// See `RedisClient.send(command:with:)`
    public func send(
        command: String,
        with arguments: [RESPValueConvertible]
    ) -> EventLoopFuture<RESPValue> {
        return self.withConnection { $0.send(command: command, with: arguments) }
    }
}

extension ConnectionPool where Source.Connection: RedisConnection {
    /// Sources a connection and forwards the command to the `RedisConnection` instance.
    ///
    /// See `RedisConnection.makePipeline()`
    public func makePipeline() -> EventLoopFuture<RedisPipeline> {
        return self.withConnection {
            return self.eventLoop.makeSucceededFuture(
                $0.makePipeline()
            )
        }
    }
}
