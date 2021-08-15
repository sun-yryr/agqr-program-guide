import Vapor

struct OldProgram: Content {
    let title: String
    let ft: Date
    let to: Date
    let pfm: String
    let dur: Int
    let isBroadCast: Bool
    let isRepeat: Bool

    init(from: Program) {
        title = from.title
        ft = from.startDatetime
        to = from.endDatetime
        pfm = from.personalities.map { $0.name }.joined(separator: ",")
        dur = from.dur
        isBroadCast = true
        isRepeat = from.isRepeat
    }
}
