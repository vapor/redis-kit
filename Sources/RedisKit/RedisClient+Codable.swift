import RediStack
import AsyncKit
import Foundation

extension RedisClient {
    /// Gets key as a `RedisDataConvertible` type.
    public func get<D>(_ key: String, as type: D.Type) -> EventLoopFuture<D?> where D: RESPValueConvertible {
        return get(key).map { value in
            guard let value = value else {
                return nil
            }
            if value.isEmpty {
                return nil
            } else {
                let value = RESPValue(value)
                return D(fromRESP: value)
            }
        }
    }

    // MARK: JSON

    /// Gets key as a decodable type.
    public func jsonGet<D>(_ key: String, as type: D.Type) -> EventLoopFuture<D?> where D: Decodable {
        return get(key, as: Data.self).flatMapThrowing { data in
            return try data.flatMap { data in
                return try JSONDecoder().decode(D.self, from: data)
            }
        }
    }

    /// Sets key to an encodable item.
    public func jsonSet<E>(_ key: String, to entity: E) -> EventLoopFuture<Void> where E: Encodable {
        do {
            return try set(key, to: JSONEncoder().encode(entity))
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
}
