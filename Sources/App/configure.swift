import Fluent
import FluentMySQLDriver
import Leaf
import Queues
import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(
        .mysql(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database",
            tlsConfiguration: .forClient(certificateVerification: .none)
        ), as: .mysql)

    app.migrations.add(CreateProgram())
    app.migrations.add(CreatePersonality())
    app.migrations.add(CreateProgramPersonality())

    app.views.use(.leaf)

    app.commands.use(
        ScrapingAgqr(parser: DailyProgramGuideParser(), repository: ProgramGuideRepository()), as: "scraping")

    try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
    app.queues.schedule(
        ImportProgramGuideJob(parser: DailyProgramGuideParser(), repository: ProgramGuideRepository())
    )
    .minutely()
    .at(0)
    // try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()

    // register routes
    try routes(app)
}
