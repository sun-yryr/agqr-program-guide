import Fluent

struct CreateProgram: Migration {
    private let tableName = Program.schema

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName)
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .field("info", .sql(raw: "TEXT"), .required)
            .field("url", .string, .required)
            .field("start_datetime", .datetime, .required)
            .field("end_datetime", .datetime, .required)
            .field("dur", .int, .required)
            .field("is_repeat", .bool, .required)
            .field("is_movie", .bool, .required)
            .field("is_live", .bool, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .unique(on: "start_datetime")
            .unique(on: "end_datetime")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(self.tableName).delete()
    }
}
