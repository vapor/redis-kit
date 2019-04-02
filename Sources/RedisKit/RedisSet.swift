extension RedisClient {
    /// Creates a `RedisSet` referencing a set stored in Redis at `key` with values of `type`.
    ///
    ///     let setOfIDs = client.makeRedisSet(key: String, type: Int.self)
    ///     // setOfIDs represents a Set of `Int`.
    ///
    /// - Parameters:
    ///     - key: The Redis key to identify the set.
    ///     - type: The Swift type representation of the elements in the set.
    /// - Returns: A `RedisSet` for the key and element type specified.
    @inlinable
    public func makeRedisSet<T>(key: String, type: T.Type = T.self) -> RedisSet<T> {
        return RedisSet(identifier: key, client: self)
    }
}

/// A reference to a specific Set in a Redis instance.
///
/// https://redis.io/topics/data-types-intro#sets
public struct RedisSet<Element> where Element: RESPValueConvertible {
    @usableFromInline
    let id: String
    @usableFromInline
    let client: RedisClient

    /// Creates a reference to a specific Redis key that holds a Set type value.
    /// - Parameters:
    ///     - identifier: The key identifier to reference this set.
    ///     - client: The `RedisClient` to use for making calls to Redis.
    public init(identifier: String, client: RedisClient) {
        self.id = identifier
        self.client = client
    }

    /// Gets the total count of elements in the set.
    /// - Note: In most cases it's better to call `RedisSet.allElements`.
    ///
    /// See `RedisClient.scard(of:)`
    @inlinable
    var count: EventLoopFuture<Int> { return client.scard(of: id) }

    /// Gets all of the elements in the set.
    ///
    /// See `RedisClient.smembers(of:)`
    @inlinable
    var allElements: EventLoopFuture<[Element]?> {
        return client.smembers(of: id)
            .map { $0.compactMap(Element.init) }
    }

    /// Checks if the provided element is currently in the set.
    ///
    /// See `RedisClient.sismember(_:of:)`
    /// - Parameter element: The value to search for.
    /// - Returns: `true` if the value is the set.
    @inlinable
    public func contains(_ element: Element) -> EventLoopFuture<Bool> {
        return client.sismember(element, of: id)
    }

    /// Inserts the provided elements into the set.
    /// - Note: Values already in the set will be ignored.
    ///
    /// See `RedisClient.sadd(_:to:)`
    /// - Returns: `true` if at least 1 element was inserted.
    @inlinable
    @discardableResult
    public func insert(_ elements: [Element]) -> EventLoopFuture<Bool> {
        return client.sadd(elements, to: id)
            .map { return $0 > 0 }
    }

    /// Inserts the provided elements into the set.
    /// - Note: Values already in the set will be ignored.
    ///
    /// See `RedisClient.sadd(_:to:)`
    /// - Returns: `true` if at least 1 element was inserted.
    @inlinable
    @discardableResult
    public func insert(_ elements: Element...) -> EventLoopFuture<Bool> {
        return insert(elements)
    }

    /// Removes the specified elements from the set.
    /// - Note: Values not in the set will be ignored.
    ///
    /// See `RedisClient.srem`
    /// - Returns: `true` if at least 1 element was removed.
    @inlinable
    @discardableResult
    public func remove(_ elements: [Element]) -> EventLoopFuture<Bool> {
        return client.srem(elements, from: id)
            .map { return $0 > 0 }
    }

    /// Removes the specified elements from the set.
    /// - Note: Values not in the set will be ignored.
    ///
    /// See `RedisClient.srem`
    /// - Returns: `true` if at least 1 element was removed.
    @inlinable
    @discardableResult
    public func remove(_ elements: Element...) -> EventLoopFuture<Bool> {
        return remove(elements)
    }

    /// Removes all values within the set.
    ///
    /// See `RedisClient.delete(_:)`
    /// - Returns: The success of deleting the values stored in the set.
    @inlinable
    @discardableResult
    public func removeAll() -> EventLoopFuture<Bool> {
        return client.delete([id])
            .map { $0 == 1 }
    }

    /// Randomly selects an element and removes it from the set.
    ///
    /// See `RedisClient.spop(from:)`
    /// - Returns: The element that was selected or `nil`.
    @inlinable
    public func popRandomElement() -> EventLoopFuture<Element?> {
        return client.spop(from: id)
            .map { response in
                guard response.count > 0 else { return nil }
                return Element(response[0])
            }
    }

    /// Randomly multiple elements and removes them from the set.
    ///
    /// See `RedisClient.spop(from:max:)`
    /// - Parameter count: The max number of elements that should be popped from the set.
    /// - Returns: A list of elements that were randomly selected.
    @inlinable
    public func popRandomElements(max count: Int = 1) -> EventLoopFuture<[Element]> {
        return client.spop(from: id, max: count)
            .map { return $0.compactMap(Element.init) }
    }

    /// Randomly selects a single element.
    ///
    /// See `RedisClient.srandmember(from:)`
    /// - Returns: The element that was selected or `nil`.
    @inlinable
    public func randomElement() -> EventLoopFuture<Element?> {
        return client.srandmember(from: id)
            .map { response in
                guard response.count > 0 else { return nil }
                return Element(response[0])
            }
    }

    /// Randomly selects multiple elements, up to the `max` specified.
    ///
    ///     // assume `set` has 3 elements
    ///
    ///     // returns all 3 elements
    ///     set.random(max: 4, allowDuplicates: false)
    ///     // returns 4 elements, with a duplicate
    ///     set.random(max: 4, allowDuplicates: true)
    ///
    /// See `RedisClient.srandmember(from:max:)`
    /// - Parameters:
    ///     - max: The max number of elements to pull, as available.
    ///     - allowDuplicates: Should duplicate elements be picked?
    /// - Returns: The elements randomly selected from the set.
    @inlinable
    public func randomElements(max: Int = 1, allowDuplicates: Bool = false) -> EventLoopFuture<[Element]> {
        assert(max > 0, "Max should be a positive value. Use 'allowDuplicates' to handle proper value sign")

        let count = allowDuplicates ? -max : max
        return client.srandmember(from: id, max: count)
            .map { $0.compactMap(Element.init) }
    }
}
