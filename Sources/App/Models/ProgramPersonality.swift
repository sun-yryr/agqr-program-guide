import Fluent

final class ProgramPersonality: Model, @unchecked Sendable {
    static let schema = "programs+personalities"

    @ID(custom: "id")
    var id: Int?

    @Parent(key: "program_id")
    var program: Program

    @Parent(key: "personality_id")
    var personality: Personality

    init() {}

    init(id: Int? = nil, program: Program, personality: Personality) throws {
        self.id = id
        self.$program.id = try program.requireID()
        self.$personality.id = try personality.requireID()
    }
}
