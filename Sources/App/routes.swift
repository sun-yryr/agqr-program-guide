import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { _ -> String in
        return "Hello, world!"
    }

    try app.group("api") { builder in
        try builder.register(collection: OldProgramController())
    }
}
