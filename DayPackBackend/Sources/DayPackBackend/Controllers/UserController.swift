// Controllers/UserController.swift
import Fluent
import Vapor

struct UserController: RouteCollection, @unchecked Sendable {
    let service: any UserServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userID") { user in
            user.get(use: show)
            user.put(use: update)
            user.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [UserResponseDTO] {
        try await service.findAll(on: req.db)
    }

    func show(req: Request) async throws -> UserResponseDTO {
        guard let id = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> UserResponseDTO {
        let dto = try req.content.decode(UserCreateDTO.self)
        return try await service.create(dto: dto, on: req.db)
    }

    func update(req: Request) async throws -> UserResponseDTO {
        guard let id = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        let dto = try req.content.decode(UserUpdateDTO.self)
        return try await service.update(id: id, dto: dto, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }
}
