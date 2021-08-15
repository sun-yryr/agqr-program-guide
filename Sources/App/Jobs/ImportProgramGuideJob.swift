import Foundation
import Queues
import Vapor

struct ImportProgramGuideJob: ScheduledJob {
    let parser: ProgramGuideParsing
    let repository: ProgramGuideSaving
    let client = DownloadAgqrProgramGuide()

    func run(context: QueueContext) -> EventLoopFuture<Void> {
        // TODO: ログの生成場所・時間
        context.logger.info("Start Scraping Process")
        defer {
            context.logger.info("End Scraping Process")
        }

        return client.fetchWeekly(app: context.application).flatMap { responses -> EventLoopFuture<Void> in
            responses
                .map { response -> EventLoopFuture<Void> in
                    guard let response = response else {
                        return context.application.eventLoopGroup.future(error: "番組表データがありませんでした。")
                    }
                    let programGuide = self.parser.parse(response)
                    return self.repository.save(programGuide, app: context.application)
                }
                .flatten(on: context.application.eventLoopGroup.next())
        }
    }
}
