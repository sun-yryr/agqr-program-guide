import Fluent
import Vapor

struct OldProgramController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("all", use: weekly(req:))
        routes.get("today", use: daily(req:))
        routes.get("now", use: now(req:))
    }

    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyyMMddHHmm"
        return df
    }()

    static let headers: HTTPHeaders = {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")
        return headers
    }()

    static let oldProgramEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Self.dateFormatter)
        encoder.outputFormatting = .withoutEscapingSlashes
        return encoder
    }()

    func weekly(req: Request) throws -> EventLoopFuture<Response> {
        let isRepeat = (try? req.query.get(Bool.self, at: "isRepeat")) ?? false
        let startDate = { () -> Date in
            var tmp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            tmp.setValue(0, for: .hour)
            tmp.setValue(0, for: .minute)
            return Calendar.current.date(from: tmp)!
        }()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!

        return Program.query(on: req.db)
            .with(\.$personalities)
            .filter(\.$startDatetime >= startDate)
            .filter(\.$startDatetime < endDate)
            .filter(\.$isRepeat ~~ [false, isRepeat])
            .all()
            .map { programs -> Response in
                let oldPrograms = programs.map { OldProgram(from: $0) }
                return Response(
                    status: .ok,
                    headers: Self.headers,
                    body: .init(data: try! Self.oldProgramEncoder.encode(oldPrograms))
                )
            }
    }

    func daily(req: Request) throws -> EventLoopFuture<Response> {
        let isRepeat = (try? req.query.get(Bool.self, at: "isRepeat")) ?? false
        let startDate = { () -> Date in
            var tmp = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            tmp.setValue(0, for: .hour)
            tmp.setValue(0, for: .minute)
            return Calendar.current.date(from: tmp)!
        }()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!

        return Program.query(on: req.db)
            .with(\.$personalities)
            .filter(\.$startDatetime >= startDate)
            .filter(\.$startDatetime < endDate)
            .filter(\.$isRepeat ~~ [false, isRepeat])
            .all()
            .map { programs -> Response in
                let oldPrograms = programs.map { OldProgram(from: $0) }
                return Response(
                    status: .ok,
                    headers: Self.headers,
                    body: .init(data: try! Self.oldProgramEncoder.encode(oldPrograms))
                )
            }
    }

    func now(req: Request) throws -> EventLoopFuture<Response> {
        let now = Date()

        return Program.query(on: req.db)
            .with(\.$personalities)
            .filter(\.$startDatetime <= now)
            .filter(\.$endDatetime > now)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { program -> Response in
                let oldProgram = OldProgram(from: program)
                return Response(
                    status: .ok,
                    headers: Self.headers,
                    body: .init(data: try! Self.oldProgramEncoder.encode(oldProgram))
                )
            }
    }
}
