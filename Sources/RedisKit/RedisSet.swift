// TODO: Re-implement RedisSet
//extension RedisDatabase {
    /// Creates a `RedisSet` for the provided key, that contains the declared type of elements.
    ///
    ///     let idSet = redis.createSetReference(fromKey: "ids", ofType: Int.self)
    ///     // idSet represents a Set of `Int`.
    ///
    /// - Parameter fromKey: The key to identify the Set in this `RedisClient`.
    /// - Parameter ofType: The type of the elements contained within the set.
//    public func createSetReference<T>(fromKey key: String, ofType type: T.Type) -> RedisSet<T> {
//        return RedisSet(identifier: key, using: self)
//    }

    /// Creates a `RedisSet` for the provided key, representing a `Collection` type.
    ///
    ///     let idSet = redis.createSetReference(fromKey: "ids", ofType: [Int].self)
    ///     // idSet represents a Set of `Int`.
    ///
    /// - Parameter fromKey: The key to identify the Set in this `RedisClient`.
    /// - Parameter ofType: The `Collection` type this set represents.
//    public func createSetReference<C: Collection>(fromKey key: String, ofType type: C.Type) -> RedisSet<C.Element>
//        where C.Element: RESPValueConvertible
//    {
//        return RedisSet(identifier: key, using: self)
//    }
//}

/// A reference to a specific Set in a Redis instance.
///
/// https://redis.io/topics/data-types-intro#sets
//public struct RedisSet<Element> where Element: RESPValueConvertible {
//    private let id: String
//    private let redis: RedisDatabase

    /// - Parameter identifier: The key identifier to reference this set.
    /// - Parameter using: The connection pool to use for interacting with this set reference.
//    public init(
//        identifier: String,
//        using redis: RedisDatabase
//    ) {
//        self.id = identifier
//        self.redis = redis
//    }

    /// Returns the total count of elements in the set.
    /// - Note: In most cases it's better to call `RedisSet.allElements`.
//    var count: EventLoopFuture<Int> {
//        return redis.command("SCARD", [RESPValue(stringLiteral: self.id)])
//    }

    /// A EventLoopFuture that resolves all elements in the set - or nil if none found.
//    var allElements: EventLoopFuture<[Element]?> {
//        return connectionPool.withConnection { $0.smembers(self.id) }
//            .map {
//                guard let set = $0.array else { return nil }
//                return try set.map { try Element.convertFromRedisData($0) }
//            }
//    }

    /// Checks if the provided element is currently in the set.
//    public func contains(_ element: Element) -> EventLoopFuture<Bool> {
//        guard let data = try? element.convertToRESP() else {
//            return connectionPool.eventLoop.makeFailedFuture(
//                RedisError(identifier: "\(#file).\(#function)", reason: "Failed to convert to RedisData: \(element)")
//            )
//        }
//
//        return connectionPool.withConnection { $0.sismember(self.id, item: data) }
//    }

    /// Inserts the provided elements into the set.
    /// - Note: Values already in the set will be ignored.
    /// - Important: This resolves `true` if at least 1 element was inserted.
//    @discardableResult
//    public func insert(_ elements: [Element]) -> EventLoopFuture<Bool> {
//        guard let data = try? elements.map({ try $0.convertToRESP()() }) else {
//            return connectionPool.eventLoop.makeFailedFuture(
//                RedisError(identifier: "\(#file).\(#function)", reason: "Failed to convert to RedisData: \(elements)")
//            )
//        }
//
//        return connectionPool.withConnection { $0.sadd(self.id, items: data) }
//            .map { return $0 > 0 }
//    }

    /// Inserts the provided elements into the set.
    /// - Note: Values already in the set will be ignored.
    /// - Important: This resolves `true` if at least 1 element was inserted.
//    @discardableResult
//    public func insert(_ elements: Element...) -> EventLoopFuture<Bool> {
//        return insert(elements)
//    }

    /// Removes the provided elements from the set.
    /// - Note: Values not in the set will be ignored.
    /// - Important: This resolves `true` if at least 1 element was removed.
//    @discardableResult
//    public func remove(_ elements: [Element]) -> EventLoopFuture<Bool> {
//        guard let data = try? elements.map({ try $0.convertToRESP() }) else {
//            return connectionPool.eventLoop.makeFailedFuture(
//                RedisError(identifier: "\(#file).\(#function)", reason: "Failed to convert to RedisData: \(elements)")
//            )
//        }
//
//        return connectionPool.withConnection { $0.srem(self.id, items: data) }
//            .map { return $0 > 0 }
//    }

    /// Removes the provided elements from the set.
    /// - Note: Values not in the set will be ignored.
    /// - Important: This resolves `true` if at least 1 element was removed.
//    @discardableResult
//    public func remove(_ elements: Element...) -> EventLoopFuture<Bool> {
//        return remove(elements)
//    }

    /// Removes all values within this set.
    /// - Important: This resolves `true` only if the set was not empty.
//    @discardableResult
//    public func removeAll() -> EventLoopFuture<Bool> {
//        return self.redis.command("DEL", [.init(stringLiteral: self.id)])
//            .map { return ($0.string.flatMap(Int.init) ?? 0) > 0 }
//    }

    /// Randomly selects an element and removes it from the set.
//    public func popRandom() -> EventLoopFuture<Element?> {
//        return connectionPool.withConnection { $0.spop(self.id) }
//            .flatMap {
//                guard !$0.isNull else { return nil }
//                return try Element.convertFromRESP($0)
//            }
//    }

    /// Randomly selects a single element.
//    public func random() -> EventLoopFuture<Element?> {
//        return connectionPool.withConnection { $0.srandmember(self.id) }
//            .map { return try Element.convertFromRESP($0) }
//    }

    /// Randomly selects random elements, up to the `max` specified.
    ///
    ///     // assume `set` has 3 elements
    ///
    ///     // returns all 3 elements
    ///     set.random(max: 4, allowDuplicates: false)
    ///     // returns 4 elements, with a duplicate
    ///     set.random(max: 4, allowDuplicates: true)
    ///
    /// - Parameter max: The max number of elements to pull, as available.
    /// - Parameter allowDuplicates: Should duplicate elements be picked?
//    public func random(max: Int = 1, allowDuplicates: Bool = false) -> EventLoopFuture<[Element]?> {
//        precondition(max > 0, "Max should be a positive value. Use 'allowDuplicates' to handle proper value sign")
//
//        guard max > 1 else { return random() }
//
//        let count = allowDuplicates ? -max : max
//        return connectionPool.withConnection { $0.srandmember(self.id, max: count) }
//            .map {
//                guard let results = $0.array else { return nil }
//                return try results.map { try Element.convertFromRESP($0) }
//            }
//    }
//}
