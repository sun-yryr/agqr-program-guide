import Fluent

struct CreatePersonality: Migration {
    private let tableName = Personality.schema

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName)
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("info", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName).delete()
    }
}
