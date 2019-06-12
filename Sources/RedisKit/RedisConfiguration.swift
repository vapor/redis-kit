@_exported import struct Foundation.URL
@_exported import struct Logging.Logger

/// A configuration for making connections to a specific Redis server.
public struct RedisConfiguration {
    public let hostname: String
    public let port: Int
    public let password: String?
    /// The database ID to connect to automatically.
    /// - Note: If nil, connections will default to `0`.
    public let database: Int?
    /// The base `Logger` to use for logging.
    /// - Note: If nil, a default will be created.
    public let logger: Logger?
    
    public init(
        hostname: String = "localhost",
        port: Int = RedisConnection.defaultPort,
        password: String? = nil,
        database: Int? = nil,
        logger: Logger? = nil
    ) {
        self.hostname = hostname
        self.port = port
        self.password = password
        self.database = database
        self.logger = logger
    }
    
    public init?(url: URL, logger: Logger? = nil) {
        guard url.scheme == "redis" else {
            return nil
        }
        self.hostname = url.host ?? "localhost"
        self.port = url.port ?? RedisConnection.defaultPort
        self.password = url.password
        self.database = Int(url.path)
        self.logger = logger
    }
}
