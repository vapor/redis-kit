import NIORedis

public protocol RedisDatabase {
    var eventLoop: EventLoop { get }
    func command(_ command: String, _ arguments: [RESPValue]) -> EventLoopFuture<RESPValue>
}

extension RedisConnection: RedisDatabase {
    public func command(_ command: String, _ arguments: [RESPValue]) -> EventLoopFuture<RESPValue> {
        do {
            return try self.send(command: command, with: arguments)
        } catch {
            return self.eventLoop.makeFailedFuture(error)
        }
    }
}

extension ConnectionPool: RedisDatabase where Source.Connection: RedisDatabase {
    public var eventLoop: EventLoop {
        return self.source.eventLoop
    }
    
    public func command(_ command: String, _ arguments: [RESPValue]) -> EventLoopFuture<RESPValue> {
        return self.withConnection { $0.command(command, arguments) }
    }
}
