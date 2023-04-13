import Fluent
import Vapor

struct ScrapingAgqr: Command {
    let parser: ProgramGuideParsing
    let repository: ProgramGuideSaving
    let client = DownloadAgqrProgramGuide()

    struct Signature: CommandSignature {
        @Option(name: "url")
        var url: String?
    }

    var help: String = "Download program guide and parse to json."

    func run(using context: CommandContext, signature: Signature) throws {
        context.console.info("Start Process")
        defer {
            context.console.info("End Process")
        }
        let future = client.execute(app: context.application, url: signature.url)
            .unwrap(or: fatalError("htmlデータの取得に失敗しました"))
            .flatMap { res -> EventLoopFuture<Void> in
                do {
                    let programGuide = try self.parser.parse(res)
                    context.console.info(programGuide.map { element in element.program.startDatetime.toString() }.joined(separator: ","))
                    return context.application.eventLoopGroup.future()
                } catch {
                    return context.application.eventLoopGroup.future(error: error)
                }
            }

        do {
            try future.wait()
        } catch {
            print("Batch failure")
            print(error.localizedDescription)
        }
    }
}
