import Fluent

struct CreateProgramPersonality: Migration {
    private let tableName = ProgramPersonality.schema
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName)
            .field("id", .int, .identifier(auto: true))
            .field("program_id", .int, .required, .references(Program.schema, "id"))
            .field("personality_id", .int, .required, .references(Personality.schema, "id"))
            .unique(on: "program_id", "personality_id")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName).delete()
    }
}
