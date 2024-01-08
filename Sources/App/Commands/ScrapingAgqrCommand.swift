import Fluent
import Vapor

struct ScrapingAgqr: Command {
    let parser: ProgramGuideParsing
    let repository: ProgramGuideSaving
    let client = DownloadAgqrProgramGuide()

    struct Signature: CommandSignature {
        @Argument(name: "url")
        var url: String
    }

    var help: String = "Download program guide and parse to json."

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
        let response = await client.execute(app: context.application, url: signature.url)
        guard let response = response else {
            context.console.error("htmlデータの取得に失敗しました")
            return
        }
        do {
            let programGuide = try parser.parse(response)
            context.console.info(programGuide.map { element in element.program.startDatetime.toString() }.joined(separator: "\n"))
            await repository.save(programGuide, app: context.application)
        } catch {
            context.console.error(.init(stringLiteral: error.localizedDescription))
        }
    }
}
