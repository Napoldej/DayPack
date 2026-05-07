
// Controllers/CheckSessionController.swift
import Fluent
import Vapor

struct CheckSessionController: RouteCollection, @unchecked Sendable {
    let service: any CheckSessionServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let sessions = routes.grouped("check-sessions")
        sessions.get(use: index)
        sessions.post(use: create)
        sessions.group(":sessionID") { session in
            session.get(use: show)
            session.delete(use: delete)
            session.patch("complete", use: complete)
        }
    }

    func index(req: Request) async throws -> [CheckSessionResponseDTO] {
        guard let loadoutID = req.query[UUID.self, at: "loadoutID"] else {
            throw Abort(.badRequest, reason: "loadoutID query parameter is required")
        }
        return try await service.findAll(for: loadoutID, on: req.db)
    }

    func show(req: Request) async throws -> CheckSessionResponseDTO {
        guard let id = req.parameters.get("sessionID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid session ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> CheckSessionResponseDTO {
        let dto = try req.content.decode(CheckSessionCreateDTO.self)
        return try await service.create(dto: dto, on: req.db)
    }

    func complete(req: Request) async throws -> CheckSessionResponseDTO {
        guard let id = req.parameters.get("sessionID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid session ID")
        }
        return try await service.complete(id: id, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("sessionID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid session ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }
}
