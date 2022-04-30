@testable import App
import XCTVapor

final class AppTests: ControllerBaseTestCase {
    func testHelloWorld() throws {
        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
}
