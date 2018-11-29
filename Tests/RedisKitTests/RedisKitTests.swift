import XCTest
@testable import RedisKit

final class RedisKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(RedisKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
