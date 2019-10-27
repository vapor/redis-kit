import RediStack
import AsyncKit
import Foundation

// MARK: JSON

extension RedisClient {
    /// Gets key as a decodable type.
    public func get<D>(_ key: String, asJSON type: D.Type) -> EventLoopFuture<D?> where D: Decodable {
        return get(key, as: Data.self).flatMapThrowing { data in
            return try data.flatMap { data in
                return try JSONDecoder().decode(D.self, from: data)
            }
        }
    }

    /// Sets key to an encodable item.
    public func set<E>(_ key: String, toJSON entity: E) -> EventLoopFuture<Void> where E: Encodable {
        do {
            return try set(key, to: JSONEncoder().encode(entity))
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
}
