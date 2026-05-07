// Controllers/AuthController.swift
import Fluent
import Vapor
import JWT

struct AuthController: RouteCollection, @unchecked Sendable {
    let service: any AuthServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
    }

    func register(req: Request) async throws -> AuthResponseDTO {
        let dto = try req.content.decode(RegisterDTO.self)
        return try await service.register(dto: dto, req: req)
    }

    func login(req: Request) async throws -> AuthResponseDTO {
        let dto = try req.content.decode(LoginDTO.self)
        return try await service.login(dto: dto, req: req)
    }
}
