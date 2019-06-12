import XCTest

import RedisKitTests

var tests = [XCTestCaseEntry]()
tests += RedisKitTests.__allTests()

XCTMain(tests)
