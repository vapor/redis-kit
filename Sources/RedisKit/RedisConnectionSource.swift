public final class RedisConnectionSource: ConnectionPoolSource {
    public let eventLoop: EventLoop
    private let config: RedisConfiguration
    private let driver: RedisDriver
    
    deinit {
        try? self.driver.terminate()
        assert(!self.driver.isRunning, "Redis driver not shutdown properly!")
    }
    
    public init(config: RedisConfiguration, on eventLoop: EventLoop) {
        self.eventLoop = eventLoop
        self.config = config
        self.driver = RedisDriver(ownershipModel: .external(eventLoop))
    }
    
    public func makeConnection() -> EventLoopFuture<RedisConnection> {
        return driver.makeConnection(hostname: config.hostname, port: config.port, password: config.password)
    }
}

extension RedisConnection: ConnectionPoolItem {
    public var eventLoop: EventLoop { return channel.eventLoop }
}
