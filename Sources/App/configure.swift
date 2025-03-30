import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import NIOSSL

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // SSL設定
    let tls: PostgresConnection.Configuration.TLS
    if Environment.get("DATABASE_USE_SSL") == "true" {
        var config = TLSConfiguration.makeClientConfiguration()
        config.certificateVerification = .none
        tls = .prefer(try .init(configuration: config))
    } else {
        tls = .disable
    }
    
    let configuration = SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: tls
    )
    
    app.databases.use(
        .postgres(configuration: configuration),
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
    app.middleware.use(newCORSMiddleware())

    // register routes
    try routes(app)
}

func newCORSMiddleware() -> CORSMiddleware {
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .OPTIONS, .HEAD],
        allowedHeaders: [
            .accept, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin,
        ]
    )
    return CORSMiddleware(configuration: corsConfiguration)
}
