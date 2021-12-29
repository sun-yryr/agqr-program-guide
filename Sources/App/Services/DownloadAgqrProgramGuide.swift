import Vapor

struct DownloadAgqrProgramGuide {
    // swift-format-ignore
    static let AGQR_URL = "https://www.joqr.co.jp/qr/agdailyprogram/"

    func fetchToday(app: Application) async -> Data? {
        return await self.execute(app: app, url: Self.AGQR_URL)
    }

    func fetchWeekly(app: Application) async -> [Data?] {
        // query date format=yyyyMMdd
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        // 今日から6日分のurlを生成する
        let urls = (0...6).map { index -> String in
            let calculateDate = Calendar.current.date(byAdding: .day, value: index, to: Date())!
            return formatter.string(from: calculateDate)
        }.map { "\(Self.AGQR_URL)?date=\($0)" }

        var responses: [Data?] = []
        await withTaskGroup(of: Data?.self) { group in
            for url in urls {
                group.addTask {
                    return await self.execute(app: app, url: url)
                }
            }

            for await response in group {
                responses.append(response)
            }
        }
        return responses
    }

    func execute(app: Application, url: String) async -> Data? {
        do {
            let response = try await app.client.get(URI(string: url)).get()
            return response.body.flatMap { buffer in
                buffer.getData(at: 0, length: buffer.writerIndex)
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
