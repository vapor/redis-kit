import XCTest

import RedisKitTests

var tests = [XCTestCaseEntry]()
tests += RedisKitTests.allTests()
XCTMain(tests)
