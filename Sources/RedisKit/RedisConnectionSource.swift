import AsyncKit
import struct Foundation.UUID
import Logging
import NIO

private let loggingKeyID = "RedisConnectionFactory"

public final class RedisConnectionSource {
    /// See `ConnectionPoolSource.eventLoop`
    public let eventLoop: EventLoop

    private let config: RedisConfiguration
    private var logger: Logger

    public init(
        config: RedisConfiguration,
        eventLoop: EventLoop,
        logger: Logger = Logger(label: "codes.vapor.redis-kit")
    ) {
        self.eventLoop = eventLoop
        self.config = config
        self.logger = logger

        self.logger[metadataKey: loggingKeyID] = "\(UUID())"
        self.logger.debug("Factory created.")
    }
}

extension RedisConnectionSource: ConnectionPoolSource {
    /// Creates a new `RediStack.RedisConnection` using the `RedisConfiguration` provided during factory init.
    /// - Note: The client will receive a logger based on the one in the configuration, with an
    ///     additional metadata key "RedisConnectionFactory" that associates the connection instance
    ///     with the factory that created it.
    ///
    /// See `ConnectionPoolSource`
    public func makeConnection() -> EventLoopFuture<RedisConnection> {
        let address: SocketAddress
        do {
            address = try SocketAddress.makeAddressResolvingHost(config.hostname, port: config.port)
        } catch {
            self.logger.error("Failed to resolve address for config: \(config)")
            return self.eventLoop.makeFailedFuture(error)
        }

        var clientLogger = self.config.logger
        clientLogger?[metadataKey: loggingKeyID] = self.logger[metadataKey: loggingKeyID]

        return self.makeConnection(to: address, with: clientLogger)
    }

    private func makeConnection(
        to address: SocketAddress,
        with clientLogger: Logger?
    ) -> EventLoopFuture<RedisConnection> {
        self.logger.debug("Making a RedisConnection.")

        let futureClient: EventLoopFuture<RedisConnection>
        if let l = clientLogger {
            futureClient = RedisConnection.connect(to: address, on: eventLoop, password: config.password, logger: l)
        } else {
            futureClient = RedisConnection.connect(to: address, on: eventLoop, password: config.password)
        }

        return futureClient
            .flatMap { client in
                guard let index = self.config.database else {
                    return self.eventLoop.makeSucceededFuture(client)
                }

                self.logger.debug("Selecting Redis database \(index) specified by config")

                return client.select(database: index)
                    .map { return client }
            }
    }
}
