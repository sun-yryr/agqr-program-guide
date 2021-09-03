import Vapor

struct DownloadAgqrProgramGuide {
    // swift-format-ignore
    static let AGQR_URL = "https://www.joqr.co.jp/qr/agdailyprogram/"

    func fetchToday(app: Application) -> EventLoopFuture<Data?> {
        return app.client.get(URI(string: Self.AGQR_URL)).map { res -> Data? in
            return res.body.flatMap { $0.getData(at: 0, length: $0.writerIndex) }
        }
    }

    func fetchWeekly(app: Application) -> EventLoopFuture<[Data?]> {
        // query date format=yyyyMMdd
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        // 今日から6日分のurlを生成する
        let urls = (0...6).map { index -> String in
            let calculateDate = Calendar.current.date(byAdding: .day, value: index, to: Date())!
            return formatter.string(from: calculateDate)
        }.map { "\(Self.AGQR_URL)?date=\($0)" }

        return urls.map { url -> EventLoopFuture<Data?> in
            app.client.get(URI(string: url)).map { res -> Data? in
                return res.body.flatMap { $0.getData(at: 0, length: $0.writerIndex) }
            }
        }.flatten(on: app.eventLoopGroup.next())
    }

    func execute(app: Application) -> EventLoopFuture<Data?> {
        return app.client.get(URI(string: Self.AGQR_URL)).map { res in
            return res.body.flatMap { $0.getData(at: 0, length: $0.writerIndex) }
        }
    }
}
