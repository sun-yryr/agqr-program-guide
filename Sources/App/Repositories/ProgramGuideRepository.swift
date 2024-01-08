import Fluent
import Vapor

protocol ProgramGuideSaving {
    func save(_ items: [ProgramGuide], app: Application) async
}

struct ProgramGuideRepository: ProgramGuideSaving {
    func save(_ items: [ProgramGuide], app: Application) async {
        for programGuide in items {
            do {
                let insertedProgram = try await upsertProgram(programGuide.program, app.db)
                var insertedPersonalities: [Personality] = []
                for personality in programGuide.personalities {
                    let p = try await upsertPersonality(personality, app.db)
                    insertedPersonalities.append(p)
                }
                for personality in insertedPersonalities {
                    let isAttached = try? await insertedProgram.$personalities.isAttached(
                        to: personality, on: app.db)
                    if isAttached == false {
                        try await insertedProgram.$personalities.attach(personality, on: app.db)
                    }
                }
            } catch {
                print("error")
                print(error.localizedDescription)
            }
        }
    }

    /// 開始時間と終了時間を基準に(unique)insert or updateを行う.
    func upsertProgram(_ program: Program, _ db: Database) async throws -> Program {
        let targetProgram = try? await Program.query(on: db)
            .filter(\.$startDatetime == program.startDatetime)
            .filter(\.$endDatetime == program.endDatetime)
            .first()

        program.id = targetProgram?.id
        // idを挿入するだけだとうまくupdateできなかったため、判定要素を上書きする
        program._$id.exists = targetProgram != nil

        try await program.save(on: db)
        return program
    }

    /// 名前を基準に(unique)insert or updateを行う.
    func upsertPersonality(_ personality: Personality, _ db: Database) async throws -> Personality {
        let targetPersonality =
            try? await Personality
            .query(on: db)
            .filter(\.$name == personality.name)
            .first()

        personality.id = targetPersonality?.id
        // idを挿入するだけだとうまくupdateできなかったため、判定要素を上書きする
        personality._$id.exists = targetPersonality != nil

        try await personality.save(on: db)
        return personality
    }
}
