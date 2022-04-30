@testable import App
import XCTVapor

final class NowTests: ControllerBaseTestCase {
    func testAPINow() async throws {
        let program = Program(title: "sample", info: "info", url: "http://example.com/", startDatetime: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!, endDatetime: Calendar.current.date(byAdding: .minute, value: 5, to: Date())!, dur: 10, isRepeat: false, isMovie: false, isLive: true)
        try await program.save(on: app.db).get()

        try app.test(.GET, "/api/now", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContains(res.body.string, "sample") // MEMO: 募 定義のないjsonをいい感じに扱う方法
        })
    }
}
