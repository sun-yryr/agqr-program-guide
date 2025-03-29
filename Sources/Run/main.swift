import App
import Vapor

// Using synchronous API because of restrictions in Swift 6
// for using shutdown in async contexts
var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
try app.run()