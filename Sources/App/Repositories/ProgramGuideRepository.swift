import Fluent
import Vapor

protocol ProgramGuideSaving {
    func save(_ items: [ProgramGuide], app: Application) -> EventLoopFuture<Void>
}

struct ProgramGuideRepository: ProgramGuideSaving {
    func save(_ items: [ProgramGuide], app: Application) -> EventLoopFuture<Void> {
        // 与えられたProgramGuideからProgramとPersonalitiesをDBに保存し、リレーションを貼る
        let res = items.map { item -> EventLoopFuture<Void> in
            // programを取得し、存在する場合は更新する
            let program = upsertProgram(item.program, app.db)
            let personalities = item.personalities.map { upsertPersonality($0, app.db) }
            // 両方の成功時にリレーションを貼る
            return personalities.map {
                $0.flatMap { personality -> EventLoopFuture<Void> in
                    program.flatMap { program -> EventLoopFuture<Void> in
                        program.$personalities.isAttached(to: personality, on: app.db).flatMap {
                            isAttach -> EventLoopFuture<Void> in
                            if !isAttach {
                                return program.$personalities.attach(personality, on: app.db)
                            }
                            return app.eventLoopGroup.future()
                        }
                    }
                }
            }
            .flatten(on: app.eventLoopGroup.next())
            .flatMapError { error in
                print(error.localizedDescription)
                return app.eventLoopGroup.future(error: error)
            }
        }
        return res.flatten(on: app.eventLoopGroup.next())
    }

    /// 開始時間と終了時間を基準に(unique)insert or updateを行う.
    func upsertProgram(_ program: Program, _ db: Database) -> EventLoopFuture<Program> {
        return
            Program
            .query(on: db)
            .filter(\.$startDatetime == program.startDatetime)
            .filter(\.$endDatetime == program.endDatetime)
            .first()
            .flatMap { dbProgram -> EventLoopFuture<Program> in
                program.id = dbProgram?.id
                // idを挿入するだけだとうまくupdateできなかったため、判定要素を上書きする
                program._$id.exists = dbProgram?.id != nil
                return program.save(on: db).transform(to: program)
            }
    }

    /// 名前を基準に(unique)insert or updateを行う.
    func upsertPersonality(_ personality: Personality, _ db: Database) -> EventLoopFuture<Personality> {
        return
            Personality
            .query(on: db)
            .filter(\.$name == personality.name)
            .first()
            .flatMap { dbPersonality -> EventLoopFuture<Personality> in
                personality.id = dbPersonality?.id
                // idを挿入するだけだとうまくupdateできなかったため、判定要素を上書きする
                personality._$id.exists = dbPersonality?.id != nil
                return personality.save(on: db).transform(to: personality)
            }
    }
}
