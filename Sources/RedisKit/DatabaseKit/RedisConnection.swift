import Foundation
import DatabaseKit
import NIORedis

extension RedisConnection: DatabaseConnection {
    public var eventLoop: EventLoop { return channel.eventLoop }
}
