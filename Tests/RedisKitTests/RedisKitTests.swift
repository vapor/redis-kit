import RedisKit
import XCTest

final class RedisKitTests: XCTestCase {
    func testVersion() throws {
        let response = try self.client.send(command: "INFO").wait()
        XCTAssert(response.string?.contains("connected_clients:1") == true, "unexpected response")
    }

    func testIsClosed() throws {
        let _: Void = try self.connectionPool.withConnection { connection in
            XCTAssertEqual(connection.isClosed, false)
            return connection.eventLoop.makeSucceededFuture(())
        }.wait()
    }

    func testCRUD() throws {
        try self.client.set("hello", to: "world").wait()
        let get = try self.client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")
        let _ = try self.client.delete(["hello"]).wait()
        XCTAssertNil(try self.client.get("hello", as: String.self).wait())
    }

    func testSelect() throws {
        let _ = try self.client.select(database: 2).wait()
        try self.client.set("hello", to: "world").wait()
        let get = try self.client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")

        let _ = try self.client.select(database: 0).wait()
        XCTAssertNil(try self.client.get("hello", as: String.self).wait())

        let _ = try self.client.select(database: 2).wait()
        let reget = try self.client.get("hello", as: String.self).wait()
        XCTAssertEqual(reget, "world")

        let _ = try self.client.delete(["hello"]).wait()
        XCTAssertNil(try self.client.get("hello", as: String.self).wait())
    }

    func testSelectViaConfig() throws {
        try self.connectionPool.close().wait()
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let hostname: String
        #if os(Linux)
        hostname = "redis"
        #else
        hostname = "localhost"
        #endif

        let source = RedisConnectionSource(config: .init(
            hostname: hostname,
            port: 6379,
            password: nil,
            database: 2,
            logger: nil
        ), eventLoop: self.eventLoopGroup.next())
        self.connectionPool = .init(config: .init(maxConnections: 4), source: source)

        try self.client.set("hello", to: "world").wait()
        let get = try self.client.get("hello", as: String.self).wait()
        XCTAssertEqual(get, "world")

        let _ = try self.client.select(database: 0).wait()
        XCTAssertNil(try self.client.get("hello", as: String.self).wait())

        let _ = try self.client.select(database: 2).wait()
        let reget = try self.client.get("hello", as: String.self).wait()
        XCTAssertEqual(reget, "world")

        let _ = try self.client.delete(["hello"]).wait()
        XCTAssertNil(try self.client.get("hello", as: String.self).wait())

        try! eventLoopGroup.syncShutdownGracefully()
    }

    #warning("needs implementation")
    func testPubSubSingleChannel() throws {
        /*
        let futureExpectation = expectation(description: "Subscriber should receive message")

        let redisSubscriber = try RedisClient.makeTest()
        let redisPublisher = try RedisClient.makeTest()
        defer {
            redisPublisher.close()
            redisSubscriber.close()
        }

        let channel1 = "channel1"
        let channel2 = "channel2"

        let expectedChannel1Msg = "Stuff and things"
        _ = try redisSubscriber.subscribe(Set([channel1])) { channelData in
            if channelData.data.string == expectedChannel1Msg {
                futureExpectation.fulfill()
            }
        }.catch { _ in
            XCTFail("this should not throw an error")
        }

        _ = try redisPublisher.publish("Stuff and things", to: channel1).wait()
        _ = try redisPublisher.publish("Stuff and things 3", to: channel2).wait()
        waitForExpectations(timeout: defaultTimeout)*/
    }

    #warning("needs implementation")
    func testPubSubMultiChannel() throws {
        /*
        let expectedChannel1Msg = "Stuff and things"
        let expectedChannel2Msg = "Stuff and things 3"
        let futureExpectation1 = expectation(description: "Subscriber should receive message \(expectedChannel1Msg)")
        let futureExpectation2 = expectation(description: "Subscriber should receive message \(expectedChannel2Msg)")
        let redisSubscriber = try RedisClient.makeTest()
        let redisPublisher = try RedisClient.makeTest()
        defer {
            redisPublisher.close()
            redisSubscriber.close()
        }

        let channel1 = "channel/1"
        let channel2 = "channel/2"

        _ = try redisSubscriber.subscribe(Set([channel1, channel2])) { channelData in
            if channelData.data.string == expectedChannel1Msg {
                futureExpectation1.fulfill()
            } else if channelData.data.string == expectedChannel2Msg {
                futureExpectation2.fulfill()
            }
        }.catch { _ in
            XCTFail("this should not throw an error")
        }
        _ = try redisPublisher.publish("Stuff and things", to: channel1).wait()
        _ = try redisPublisher.publish("Stuff and things 3", to: channel2).wait()
        waitForExpectations(timeout: defaultTimeout)*/
    }

    func testStruct() throws {
        struct Hello: Codable {
            var message: String
            var array: [Int]
            var dict: [String: Bool]
        }
        let hello = Hello(message: "world", array: [1, 2, 3], dict: ["yes": true, "false": false])
        try self.client.set("hello", toJSON: hello).wait()
        let get = try self.client.get("hello", asJSON: Hello.self).wait()
        XCTAssertEqual(get?.message, "world")
        XCTAssertEqual(get?.array.first, 1)
        XCTAssertEqual(get?.array.last, 3)
        XCTAssertEqual(get?.dict["yes"], true)
        XCTAssertEqual(get?.dict["false"], false)
        let _ = try self.client.delete(["hello"]).wait()
    }

    func testStringCommands() throws {
        let values = ["hello": RESPValue(bulk: "world"), "hello2": RESPValue(bulk: "world2")]
        try self.client.mset(values).wait()
        let resp = try self.client.mget(["hello", "hello2"]).wait()
        XCTAssertEqual(resp[0].string, "world")
        XCTAssertEqual(resp[1].string, "world2")
        let _ = try self.client.delete(["hello", "hello2"]).wait()
        
        let number = try self.client.increment("number").wait()
        XCTAssertEqual(number, 1)
        let number2 = try self.client.increment("number", by: 10).wait()
        XCTAssertEqual(number2, 11)
        let number3 = try self.client.decrement("number", by: 10).wait()
        XCTAssertEqual(number3, 1)
        let number4 = try self.client.decrement("number").wait()
        XCTAssertEqual(number4, 0)
        let _ = try self.client.delete(["number"]).wait()
    }

    func testHashCommands() throws {
        // create hash value
        
        let hsetResponse = try self.client.hset("world", to: RESPValue(bulk: "whatever"), in: "hello").wait()
        XCTAssertEqual(hsetResponse, true)

        // hash field must exist
        let hexistsResponse = try self.client.hexists("world", in: "hello").wait()
        XCTAssertEqual(hexistsResponse, true)

        // get all field names
        let hkeysResponse = try self.client.hkeys(in: "hello").wait()
        XCTAssertEqual(hkeysResponse.count, 1)
        XCTAssertEqual(hkeysResponse.first, "world")

        // update hash value
        let hsetResponse2 = try self.client.hset("world", to: RESPValue(bulk: "value"), in: "hello").wait()
        XCTAssertEqual(hsetResponse2, false)

        // get hash value
        #warning("hget(field:from:as:) not yet implemented")
        /*let hgetResponse = try redis.hget("hello", field: "world", as: String.self).wait()
        XCTAssertNotNil(hgetResponse)
        XCTAssertEqual(hgetResponse, "value")*/


        // create other 2 hash values
        let _ = try self.client.hset("world2", to: RESPValue(bulk: "whatever2"), in: "hello").wait()
        let _ = try self.client.hset("world3", to: RESPValue(bulk: "whatever3"), in: "hello").wait()

        // get all keys:values
        let all = try self.client.hgetall(from: "hello").wait()
        XCTAssertEqual(all.count, 3)

        // verify value
        if let value = all["world2"] {
            XCTAssertEqual(value, "whatever2")
        } else {
            XCTFail("value should exist")
        }

        // delete hash value
        let hdelResponse = try self.client.hdel(["not-existing-field"], from: "hello").wait()
        XCTAssertEqual(hdelResponse, 0)
        let hdelResponse2 = try self.client.hdel(["world"], from: "hello").wait()
        XCTAssertEqual(hdelResponse2, 1)
        let hdelResponse3 = try self.client.hdel(["world2"], from: "hello").wait()
        XCTAssertEqual(hdelResponse3, 1)
        let hdelResponse4 = try self.client.hdel(["world3"], from: "hello").wait()
        XCTAssertEqual(hdelResponse4, 1)

        // get hash value
        #warning("hget(field:from:as:) not yet implemented")
        /*let hgetResponse2 = try redis.hget("hello", field: "world", as: String.self).wait()
        XCTAssertNil(hgetResponse2)*/

        // hash field must not exist
        let hexistsResponse2 = try self.client.hexists("world", in: "hello").wait()
        XCTAssertEqual(hexistsResponse2, false)

        // Multi set hash value
        try self.client.hmset(["param1": RESPValue(bulk: "value1"), "param2": RESPValue(bulk: "value2")], in: "hash").wait()

        // Mulit get hash value
        let hmgetResp = try self.client.hmget(["param1", "bad", "param2"], from: "hash").wait()
        XCTAssertEqual(hmgetResp.count, 3)
        XCTAssertEqual(hmgetResp[0], "value1")
        XCTAssertNil(hmgetResp[1])
        XCTAssertEqual(hmgetResp[2], "value2")

        let _ = try self.client.delete(["hash"]).wait()
    }

    func testListCommands() throws {
        let _ = try self.client.send(command: "FLUSHALL").wait()

        let lpushResp = try self.client.lpush([RESPValue(bulk: "hello")], into: "mylist").wait()
        XCTAssertEqual(lpushResp, 1)

        let rpushResp = try self.client.rpush([RESPValue(bulk: "hello1")], into: "mylist").wait()
        XCTAssertEqual(rpushResp, 2)

        let length = try self.client.llen(of: "mylist").wait()
        XCTAssertEqual(length, 2)

        let item = try self.client.lindex(0, from: "mylist").wait()
        XCTAssertEqual(item.string, "hello")
        
        let items = try self.client.lrange(within: (startIndex: 0, endIndex: 1), from: "mylist").wait()
        XCTAssertEqual(items.count, 2)

        try self.client.lset(index: 0, to: RESPValue(bulk: "hello2"), in: "mylist").wait()
        let item2 = try self.client.lindex(0, from: "mylist").wait()
        XCTAssertEqual(item2.string, "hello2")

        let rpopResp = try self.client.rpop(from: "mylist").wait()
        XCTAssertEqual(rpopResp.string, "hello1")

        let rpoplpush = try self.client.rpoplpush(from: "mylist", to: "list2").wait()
        XCTAssertEqual(rpoplpush.string, "hello2")

        let lpopResp = try self.client.lpop(from: "list2").wait()
        XCTAssertEqual(lpopResp.string, "hello2")

        let blpopResp1 = try self.client.blpop(from: ["mylist"], timeout: 1).wait()
        XCTAssertNil(blpopResp1)

        let _ = try self.client.lpush([RESPValue(bulk: "hello")], into: "mylist").wait()
        let blpopResp2 = try self.client.blpop(from: ["mylist"], timeout: 1).wait()
        XCTAssertEqual(blpopResp2?.0, "mylist")
        XCTAssertEqual(blpopResp2?.1.string, "hello")

        let brpopResp1 = try self.client.brpop(from: ["mylist"], timeout: 1).wait()
        XCTAssertNil(brpopResp1)

        let _ = try self.client.lpush([RESPValue(bulk: "hello")], into: "mylist").wait()
        let brpopResp2 = try self.client.brpop(from: ["mylist"], timeout: 1).wait()
        XCTAssertEqual(brpopResp2?.0, "mylist")
        XCTAssertEqual(brpopResp2?.1.string, "hello")

        let brpoplpushResp1 = try self.client.brpoplpush(from: "mylist", to: "list2", timeout: 1).wait()
        XCTAssertNil(brpoplpushResp1)

        let _ = try self.client.lpush([RESPValue(bulk: "hello")], into: "mylist").wait()
        let brpoplpushResp2 = try self.client.brpoplpush(from: "mylist", to: "list2", timeout: 1).wait()
        XCTAssertEqual(brpoplpushResp2!.string, "hello")
        let brpoplpushResp3 = try self.client.lpop(from: "list2").wait()
        XCTAssertEqual(brpoplpushResp3.string, "hello")

        let _ = try self.client.lpush([RESPValue(bulk: "hello"), RESPValue(bulk: "hello1"), RESPValue(bulk: "hello")], into: "mylist").wait()

        XCTAssertEqual(try self.client.llen(of: "mylist").wait(), 3)
        XCTAssertEqual(try self.client.lrem("hello", from: "mylist", count: 1).wait(), 1)
        XCTAssertEqual(try self.client.llen(of: "mylist").wait(), 2)

        let _ = try self.client.delete(["mylist", "list2"]).wait()
    }

    func testExpire() throws {
        #warning("client.expire() uses TimeAmount which is deprecated in nio")
        /*let _ = try self.client.send(command: "FLUSHALL").wait()

        try self.client.set("foo", to: "bar").wait()
        XCTAssertEqual(try self.client.get("foo", as: String.self).wait(), "bar")
        let _ = try self.client.expire("foo", after: 1).wait()
        sleep(2)
        XCTAssertEqual(try self.client.get("foo", as: String.self).wait(), nil)*/
    }

    func testSetCommands() throws {
        let _ = try self.client.send(command: "FLUSHALL").wait()

        let dataSet = ["Hello", ",", "World", "!"]

        let addResp1 = try self.client.sadd([RESPValue(bulk: dataSet[0])], to: "set1").wait()
        XCTAssertEqual(addResp1, 1)
        let addResp2 = try self.client.sadd(
            [RESPValue(bulk: dataSet[1]), RESPValue(bulk: dataSet[2]), RESPValue(bulk: dataSet[3])],
            to: "set1"
        ).wait()
        XCTAssertEqual(addResp2, 3)
        let addResp3 = try self.client.sadd([RESPValue(bulk: dataSet[1])], to: "set1").wait()
        XCTAssertEqual(addResp3, 0)

        let countResp = try self.client.scard(of: "set1").wait()
        XCTAssertEqual(countResp, 4)

        let membersResp = try self.client.smembers(of: "set1").wait().map { $0.string! }
        XCTAssertTrue(membersResp.allSatisfy { dataSet.contains($0) })

        let isMemberResp1 = try self.client.sismember(RESPValue(bulk: dataSet[0]), of: "set1").wait()
        XCTAssertTrue(isMemberResp1)
        let isMemberResp2 = try self.client.sismember(RESPValue(bulk: "Vapor"), of: "set1").wait()
        XCTAssertFalse(isMemberResp2)

        let randResp1 = try self.client.srandmember(from: "set1").wait()
        XCTAssertTrue(dataSet.contains(randResp1[0].string!))
        let randResp2 = try self.client.srandmember(from: "set1", max: 2).wait()
        XCTAssertTrue(randResp2.allSatisfy { dataSet.contains($0.string!) })
        let randResp3 = try self.client.srandmember(from: "set1", max: 5).wait()
        XCTAssertTrue(randResp3.count == 4)
        let _ = try self.client.sadd([RESPValue(bulk: "Vapor"), RESPValue(bulk: "Redis")], to: "set2").wait()
        let randResp4 = try self.client.srandmember(from: "set2", max: -3).wait()
        XCTAssertTrue(randResp4.count == 3)
        let randResp5 = try self.client.srandmember(from: "set2", max: 3).wait()
        XCTAssertTrue(randResp5.count == 2)

        #warning("new client.spop() returns [RESPValue] instead of single value")
        /*let popResp = try redis.spop("set1").wait().string!
        XCTAssertTrue(dataSet.contains(popResp))
        XCTAssertEqual(try redis.scard("set1").wait(), 3)

        let itemToRemove = dataSet.first(where: { $0 != popResp })!
        let remResp1 = try redis.srem("set1", items: [RedisData(bulk: itemToRemove)]).wait()
        XCTAssertEqual(remResp1, 1)
        let remResp2 = try redis.srem("set1", items: [RedisData(bulk: "Vapor")]).wait()
        XCTAssertEqual(remResp2, 0)
        let remainingToRemove = dataSet.filter({ $0 != popResp && $0 != itemToRemove }).map { RedisData(bulk: $0) }
        let remResp3 = try redis.srem("set1", items: remainingToRemove).wait()
        XCTAssertEqual(remResp3, 2)*/
    }

    func testSortedSetCommands() throws {
        let _ = try self.client.send(command: "FLUSHALL").wait()

        let dataSet = [("1", RESPValue(bulk: "data1")),("2", RESPValue(bulk: "data2")),("4", RESPValue(bulk: "data3"))]

        #warning("zadd declaration has changed")
        /*let addResp1 = try self.client.zadd(dataSet, to: "zset1").wait()
        XCTAssertEqual(addResp1, 3)

        let countResp1 = try redis.zcount("zset1", min: "1", max: "(3").wait()
        XCTAssertEqual(countResp1, 2)

        let addResp2 = try redis.zadd("zset1", items: [("3", RedisData(bulk: "data1"))], options: ["XX"]).wait()
        XCTAssertEqual(addResp2, 0)

        let countResp2 = try redis.zcount("zset1", min: "1", max: "(3").wait()
        XCTAssertEqual(countResp2, 1)

        let rangeResp1 = try redis.zrange("zset1", start: 0, stop: 0).wait()
        XCTAssertEqual(rangeResp1.count, 1)
        XCTAssertEqual(rangeResp1[0].string, "data2")

        let rangeScoreResp1 = try redis.zrangebyscore("zset1", min: "3", max: "3").wait()
        XCTAssertEqual(rangeScoreResp1.count, 1)
        XCTAssertEqual(rangeScoreResp1[0].string, "data1")

        let rangeScoreResp2 = try redis.zrangebyscore("zset1", min: "-100", max: "100", withScores: true, limit: (1,2)).wait()
        XCTAssertEqual(rangeScoreResp2.count, 4)
        XCTAssertEqual(rangeScoreResp2[0].string, "data1")
        XCTAssertEqual(rangeScoreResp2[1].string, "3")
        XCTAssertEqual(rangeScoreResp2[2].string, "data3")
        XCTAssertEqual(rangeScoreResp2[3].string, "4")

        let _ = try redis.delete(["zset1"]).wait()*/
    }

    var client: RediStack.RedisClient {
        return self.connectionPool
    }

    var connectionPool: ConnectionPool<RedisConnectionSource>!
    var eventLoopGroup: EventLoopGroup!

    override func setUp() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let hostname: String
        #if os(Linux)
        hostname = "redis"
        #else
        hostname = "localhost"
        #endif

        let source = RedisConnectionSource(config: .init(
            hostname: hostname,
            port: 6379,
            password: nil,
            database: nil,
            logger: nil
        ), eventLoop: self.eventLoopGroup.next())
        self.connectionPool = .init(config: .init(maxConnections: 4), source: source)
    }

    override func tearDown() {
        try! self.eventLoopGroup.syncShutdownGracefully()
    }
}
