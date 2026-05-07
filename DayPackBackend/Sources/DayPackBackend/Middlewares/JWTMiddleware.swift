// Middleware/JWTMiddleware.swift
import Vapor
import JWT

struct JWTMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let bearerToken = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "Missing authorization token")
        }

        let payload = try request.jwt.verify(bearerToken, as: AppJWTPayload.self)
        request.storage[UserIDKey.self] = payload.userID

        return try await next.respond(to: request)
    }
}

struct UserIDKey: StorageKey {
    typealias Value = UUID
}

extension Request {
    var userID: UUID? {
        storage[UserIDKey.self]
    }
}
