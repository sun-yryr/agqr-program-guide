import Fluent
import Vapor

struct ImportWeeklyPGCommand: Command {
    let parser: ProgramGuideParsing
    let repository: ProgramGuideSaving
    let client = DownloadAgqrProgramGuide()

    struct Signature: CommandSignature {}

    var help: String = "Import weekly program guides into db"

    func run(using context: CommandContext, signature: Signature) throws {
        context.console.info("Start Process")
        defer {
            context.console.info("End Process")
        }

        let promise = context.application.eventLoopGroup.next().makePromise(of: Void.self)
        promise.completeWithTask {
            await self.asyncRun(using: context, signature: signature)
        }

        try promise.futureResult.wait()
    }

    func asyncRun(using context: CommandContext, signature: Signature) async {
        let responses = await client.fetchWeekly(app: context.application)
        for response in responses {
            guard let response = response else {
                context.console.error("NotFound program data")
                continue
            }
            do {
                let programGuide = try self.parser.parse(response)
                guard programGuide.count > 0 else {
                    context.console.error("parsed programs length is 0")
                    continue
                }
                await self.repository.save(programGuide, app: context.application)
                context.console.info("success: \(programGuide[0].program.startDatetime)")
            } catch let error as AgqrParseError {
                context.console.error(.init(stringLiteral: error.message))
            } catch {
                context.console.error(.init(stringLiteral: error.localizedDescription))
            }
        }
    }
}
