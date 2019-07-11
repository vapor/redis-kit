import AsyncKit
import RediStack

extension RedisConnection: ConnectionPoolItem {
    /// See `ConnectionPoolItem.isClosed`
    public var isClosed: Bool { return !self.isConnected }
}

extension ConnectionPool: RedisClient where Source.Connection: RedisConnection {
    /// See `RediStack.RedisClient.eventLoop`
    public var eventLoop: EventLoop { return self.source.eventLoop }

    /// Sources a connection and forwards the command to the `RediStack.RedisClient` instance.
    ///
    /// See `RediStack.RedisClient.send(command:with:)`
    public func send(
        command: String,
        with arguments: [RESPValue]
    ) -> EventLoopFuture<RESPValue> {
        return self.withConnection { $0.send(command: command, with: arguments) }
    }
}
