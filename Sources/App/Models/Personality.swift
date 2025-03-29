import Fluent
import Vapor

final class Personality: Model, Content, @unchecked Sendable {
    static let schema = "personalities"

    @ID(custom: "id")
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "info")
    var info: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: ProgramPersonality.self, from: \.$personality, to: \.$program)
    public var programs: [Program]

    init() {}

    init(id: Int? = nil, name: String, info: String) {
        self.id = id
        self.name = name
        self.info = info
    }
}
