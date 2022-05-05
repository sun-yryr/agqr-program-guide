import Fluent
import Foundation
import Vapor

final class Program: Model, Content {
    static let schema = "programs"

    @ID(custom: "id")
    var id: Int?

    @Field(key: "title")
    var title: String

    @Field(key: "info")
    var info: String

    @Field(key: "url")
    var url: String

    @Field(key: "start_datetime")
    var startDatetime: Date

    @Field(key: "end_datetime")
    var endDatetime: Date

    @Field(key: "dur")
    var dur: Int

    @Field(key: "is_repeat")
    var isRepeat: Bool

    @Field(key: "is_movie")
    var isMovie: Bool

    @Field(key: "is_live")
    var isLive: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Siblings(through: ProgramPersonality.self, from: \.$program, to: \.$personality)
    public var personalities: [Personality]

    // Fluentが利用
    init() {}

    init(
        id: Int? = nil, title: String, info: String, url: String, startDatetime: Date, endDatetime: Date,
        dur: Int, isRepeat: Bool, isMovie: Bool, isLive: Bool
    ) {
        self.id = id
        self.title = title
        self.info = info
        self.url = url
        self.startDatetime = startDatetime
        self.endDatetime = endDatetime
        self.dur = dur
        self.isRepeat = isRepeat
        self.isMovie = isMovie
        self.isLive = isLive
    }
}
