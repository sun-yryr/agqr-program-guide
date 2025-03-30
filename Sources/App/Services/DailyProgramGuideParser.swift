import Foundation
import Kanna

protocol ProgramGuideParsing: Sendable {
    func parse(_ content: Data) throws -> [ProgramGuide]
}

// データ取得元：日別
struct DailyProgramGuideParser: ProgramGuideParsing {
    func parse(_ content: Data) throws -> [ProgramGuide] {
        let html = try! HTML(html: content, encoding: .utf8)
        // 正規表現で日付を抜き出す
        let programDateStr = try parseDate(html: html)
        // プログラムを生成
        return html.xpath("//article")
            .filter { $0["class"]?.contains("dailyProgram-itemBox") ?? false }
            .compactMap { [programDateStr] in self.parseProgram(element: $0, date: programDateStr) }
    }

    func parseDate(html: Kanna.HTMLDocument) throws -> String {
        // xpath //li[contains(@class, 'is-currentDate')
        // textContentを正規表現で引っ掛ける
        guard let currentDateText = html.xpath("//li[contains(@class, 'is-currentDate')]").first?.text else {
            throw AgqrParseError(message: "HTMLから日付を取得できませんでした")
        }
        let regex = try! NSRegularExpression(pattern: #"\d{2}/\d{2}"#)  // MM/dd
        let mattched = regex.firstMatch(
            in: currentDateText, range: .init(location: 0, length: currentDateText.count))
        guard let date = mattched else {
            throw AgqrParseError(message: "日付のパースに失敗しました。対象のテキスト[ \(currentDateText) ]")
        }
        return (currentDateText as NSString).substring(with: date.range(at: 0))
    }

    func parseProgram(element: Kanna.XMLElement, date: String) -> ProgramGuide? {
        // dailyProgram-itemHeaderTime (startTime - endTimeの形)から時間を取得する
        let strProgramTimes = element.xpath("//h3[@class='dailyProgram-itemHeaderTime']").first!.text!
        let regex = try! NSRegularExpression(pattern: #"\d{1,2}:\d{2}"#)
        let mattches = regex.matches(
            in: strProgramTimes, range: .init(location: 0, length: strProgramTimes.count))
        let startDate = self.generateDatetime(
            date: date, time: (strProgramTimes as NSString).substring(with: mattches[0].range))
        let endDate = self.generateDatetime(
            date: date, time: (strProgramTimes as NSString).substring(with: mattches[1].range))

        // dailyProgram-itemContainer からその他の情報を取得する
        let titleElement = element.xpath("//p[@class='dailyProgram-itemTitle']/a").first!
        let personalities: [Personality] = {
            guard let itemPersonality = element.xpath("//p[@class='dailyProgram-itemPersonality']").first else {
                return []
            }
            let personalities = itemPersonality.xpath("/a").map {
                Personality(name: $0.text!, info: $0["href"]!)
            }
            if personalities.count != 0 {
                return personalities
            }
            return itemPersonality.text!
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: ",")
                .map { Personality(name: String($0), info: "") }
        }()
        let description = element.xpath("//div[contains(@class, 'dailyProgram-itemDescription')]").first!
            .text!
        let program = Program(
            title: titleElement.text!,
            info: description.trimmingCharacters(in: .whitespacesAndNewlines),
            url: titleElement["href"]!,
            startDatetime: startDate,
            endDatetime: endDate,
            dur: Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute!,
            isRepeat: element["class"]?.contains("is-repeat") ?? false,
            isMovie: (element.xpath("//i[@class='icon_program-movie']").first != nil) ? true : false,
            isLive: (element.xpath("//i[@class='icon_program-live']").first != nil) ? true : false
        )
        return .init(program: program, personalities: personalities)
    }

    // date: MM/dd
    // time: hh:mm
    func generateDatetime(date: String, time: String) -> Date {
        let date: [Int] = date.split(separator: "/").map { Int($0)! }
        let time: [Int] = time.split(separator: ":").map { Int($0)! }

        let today: DateComponents = { () -> DateComponents in
            // 現在のDateから年月日を抽出してDateComponentsを作成
            var tmp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            tmp.setValue(0, for: .hour)
            tmp.setValue(0, for: .minute)
            return tmp
        }()

        let newDateComponent: DateComponents = {
            var tmp = today
            tmp.setValue(date[0], for: .month)
            tmp.setValue(date[1], for: .day)

            // htmlから作成した日付が過去だった場合、年が切り替わっているので+1年する
            if Calendar.current.date(from: today)! > Calendar.current.date(from: tmp)! {
                tmp.setValue(tmp.year! + 1, for: .year)
            }

            return tmp
        }()

        let tmp = Calendar.current.date(
            byAdding: .minute, value: time[1], to: Calendar.current.date(from: newDateComponent)!)!
        return Calendar.current.date(byAdding: .hour, value: time[0], to: tmp)!
    }

    // 割り算の結果を(商, 余り)で返す
    func division(_ a: Int, _ b: Int) -> (Int, Int) {
        return (a / b, a % b)
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }
}
