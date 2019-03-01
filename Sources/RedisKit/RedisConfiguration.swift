@_exported import struct Foundation.URL

/// A configuration for making connections to a specific Redis server.
public struct RedisConfiguration {
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
        guard url.scheme == "redis" else {
            return nil
        }
        self.hostname = url.host ?? "localhost"
        self.port = url.port ?? 6639
        self.password = url.password
        self.database = Int(url.path)
    }
}
