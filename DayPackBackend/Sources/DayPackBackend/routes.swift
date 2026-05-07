
import Vapor
import JWT

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Public routes — no auth needed
    try app.register(collection: AuthController(
        service: AuthService(repository: UserRepository())
    ))

    // Protected routes — JWT required
    let protected = app.grouped(JWTMiddleware())

    try protected.register(collection: UserController(
        service: UserService(repository: UserRepository())
    ))
    try protected.register(collection: LoadoutController(
        service: LoadoutService(repository: LoadoutRepository())
    ))
    try protected.register(collection: ItemController(
        service: ItemService(repository: ItemRepository())
    ))
    try protected.register(collection: CheckSessionController(
        service: CheckSessionService(repository: CheckSessionRepository())
    ))
    try protected.register(collection: CheckItemController(
        service: CheckItemService(repository: CheckItemRepository())
    ))
    try protected.register(collection: SharedPackController(
        service: SharedPackService(repository: SharedPackRepository())
    ))
}
