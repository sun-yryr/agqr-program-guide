import Fluent
import FluentPostgresDriver
import Leaf
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

    let pgParser = DailyProgramGuideParser()
    let pgRepository = ProgramGuideRepository()
    app.commands.use(
        ScrapingAgqr(parser: pgParser, repository: pgRepository), as: "scraping")
    app.commands.use(
        ImportWeeklyPGCommand(parser: pgParser, repository: pgRepository), as: "import:weekly"
    )

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
