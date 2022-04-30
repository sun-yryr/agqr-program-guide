@testable import App
import XCTVapor

class ControllerBaseTestCase: XCTestCase {
    let app: Application = Application(.testing)

    override func setUp() async throws {
        try await super.setUp()
        try configure(app)
        try app.migrator.setupIfNeeded().wait()
        try app.migrator.prepareBatch().wait()
    }

    override func tearDown() async throws {
        try app.migrator.revertAllBatches().wait()
        app.shutdown()
        try await super.tearDown()
    }
}
