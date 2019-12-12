import AsyncKit
import struct Foundation.UUID
import Logging
import NIO

private let loggingKeyID = "RedisConnectionFactory"

public final class RedisConnectionSource {
    private let configuration: RedisConfiguration
    private var logger: Logger

    public init(
        configuration: RedisConfiguration,
        logger: Logger = Logger(label: "codes.vapor.redis-kit")
    ) {
        self.configuration = configuration
        self.logger = logger

        self.logger[metadataKey: loggingKeyID] = "\(UUID())"
        self.logger.debug("Factory created.")
    }
}

// MARK: ConnectionPoolSource

extension RedisConnectionSource: ConnectionPoolSource {
    /// Creates a new `RediStack.RedisConnection` using the `RedisConfiguration` provided during factory init.
    /// - Note: The client will receive a logger based on the one in the configuration, with an
    ///     additional metadata key "RedisConnectionFactory" that associates the connection instance
    ///     with the factory that created it.
    ///
    /// See `ConnectionPoolSource`
    public func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<RedisConnection> {
        let address: SocketAddress
        do {
            address = try SocketAddress.makeAddressResolvingHost(self.configuration.hostname, port: self.configuration.port)
        } catch {
            self.logger.error("Failed to resolve address for config: \(self.configuration)")
            return eventLoop.makeFailedFuture(error)
        }

        var clientLogger = self.configuration.logger
        clientLogger?[metadataKey: loggingKeyID] = self.logger[metadataKey: loggingKeyID]

        return self.makeConnection(to: address, with: clientLogger, on: eventLoop)
    }

    private func makeConnection(
        to address: SocketAddress,
        with clientLogger: Logger?,
        on eventLoop: EventLoop
    ) -> EventLoopFuture<RedisConnection> {
        self.logger.debug("Making a RedisConnection.")

        let futureClient: EventLoopFuture<RedisConnection>
        if let l = clientLogger {
            futureClient = RedisConnection.connect(to: address, on: eventLoop, password: self.configuration.password, logger: l)
        } else {
            futureClient = RedisConnection.connect(to: address, on: eventLoop, password: self.configuration.password)
        }

        return futureClient
            .flatMap { client in
                guard let index = self.configuration.database else {
                    return eventLoop.makeSucceededFuture(client)
                }

                self.logger.debug("Selecting Redis database \(index) specified by config")

                return client.select(database: index)
                    .map { return client }
            }
    }
}

// MARK: ConnectionPoolItem

extension RedisConnection: ConnectionPoolItem {
    /// See `ConnectionPoolItem.isClosed`
    public var isClosed: Bool { return !self.isConnected }
}
