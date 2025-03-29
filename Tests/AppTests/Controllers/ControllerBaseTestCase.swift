@testable import App
import XCTVapor

class ControllerBaseTestCase: XCTestCase {
    let app = Application(.testing)

    override func setUp() {
        try! configure(app)
        try! app.migrator.setupIfNeeded().wait()
        try! app.migrator.prepareBatch().wait()
    }

    override func tearDown() {
        try! app.migrator.revertAllBatches().wait()
        app.shutdown()
    }
}