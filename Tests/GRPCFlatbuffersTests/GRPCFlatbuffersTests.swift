import XCTest
@testable import GRPCFlatbuffers

final class GRPCFlatbuffersTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(GRPCFlatbuffers().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
