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
        let promise = context.eventLoop.makePromise(of: Void.self)
        promise.completeWithTask {
            await self.asyncRun(context: context)
        }
        return promise.futureResult
    }

    func asyncRun(context: QueueContext) async {
        let responses = await client.fetchWeekly(app: context.application)
        for response in responses {
            guard let response = response else {
                context.logger.error("NotFound program data")
                continue
            }
            do {
                let programGuide = try self.parser.parse(response)
                return await self.repository.save(programGuide, app: context.application)
            } catch let error as AgqrParseError {
                context.logger.error(.init(stringLiteral: error.message))
                return context.application.eventLoopGroup.future(error: error)
            } catch {
                return context.application.eventLoopGroup.future(error: error)
            }
        }
    }
}
