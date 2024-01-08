import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("redoc-static.html")
    }

    app.get("health") { _ -> Response in
        return Response(status: .ok)
    }

    try app.group("api") { builder in
        try builder.register(collection: OldProgramController())
    }
}
