import Fluent
import Vapor

struct ScrapingAgqr: Command {
    let parser: ProgramGuideParsing
    let repository: ProgramGuideSaving
    let client = DownloadAgqrProgramGuide()

    struct Signature: CommandSignature {
        @Argument(name: "path")
        var path: String
    }

    var help: String = "Download program guide and parse to json."

    func run(using context: CommandContext, signature: Signature) throws {
        context.console.info("Start Process")
        defer {
            context.console.info("End Process")
        }
        let future = client.execute(app: context.application)
            .unwrap(or: fatalError("htmlデータの取得に失敗しました"))
            .flatMap { res -> EventLoopFuture<Void> in
                let programGuide = self.parser.parse(res)
                return repository.save(programGuide, app: context.application)
            }

        do {
            try future.wait()
        } catch {
            print("Batch failure")
            print(error.localizedDescription)
        }
    }
}
