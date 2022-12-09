import XCTest
import test

class Tests: XCTestCase {
    
    func testExample() {
        XCTAssertTrue(initPassbase())
        
        let (f, t) = initPassbase(publishableApiKey: "1", customerPayload: "2")
        XCTAssertEqual("1", f)
        XCTAssertEqual("2", t)
    }
}
