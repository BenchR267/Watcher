import XCTest
@testable import Watcher

class WatcherTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Watcher().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
