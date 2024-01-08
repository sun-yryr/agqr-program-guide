@testable import App
import XCTVapor

final class AppTests: ControllerBaseTestCase {
    func testHealth() throws {
        try app.test(.GET, "health", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
