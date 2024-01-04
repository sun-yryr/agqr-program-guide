import Fluent
import FluentPostgresDriver
import Leaf
import Queues
import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.databases.use(
        .postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        ),
        as: .psql
    )

    app.migrations.add(CreateProgram())
    app.migrations.add(CreatePersonality())
    app.migrations.add(CreateProgramPersonality())

    app.views.use(.leaf)

    app.commands.use(
        ScrapingAgqr(parser: DailyProgramGuideParser(), repository: ProgramGuideRepository()), as: "scraping")

    try app.queues.use(.redis(url: Environment.get("REDIS_URL") ?? "redis://127.0.0.1:6379"))

    app.queues.schedule(
        ImportProgramGuideJob(parser: DailyProgramGuideParser(), repository: ProgramGuideRepository())
    )
    .daily()
    .at(7, 0)  // 07:00 am

    // try app.queues.startInProcessJobs(on: .default)
    try app.queues.startScheduledJobs()

    // register middleware
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .OPTIONS, .HEAD],
        allowedHeaders: [
            .accept, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin,
        ]
    )
    app.middleware.use(CORSMiddleware(configuration: corsConfiguration))

    // register routes
    try routes(app)
}
