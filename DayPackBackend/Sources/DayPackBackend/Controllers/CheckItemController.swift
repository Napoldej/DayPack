
// Controllers/CheckItemController.swift
import Fluent
import Vapor

struct CheckItemController: RouteCollection, @unchecked Sendable {
    let service: any CheckItemServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let checkItems = routes.grouped("check-items")
        checkItems.get(use: index)
        checkItems.post(use: create)
        checkItems.group(":checkItemID") { checkItem in
            checkItem.get(use: show)
            checkItem.delete(use: delete)
            checkItem.patch("toggle", use: toggle)
        }
    }

    func index(req: Request) async throws -> [CheckItemResponseDTO] {
        guard let sessionID = req.query[UUID.self, at: "sessionID"] else {
            throw Abort(.badRequest, reason: "sessionID query parameter is required")
        }
        return try await service.findAll(for: sessionID, on: req.db)
    }

    func show(req: Request) async throws -> CheckItemResponseDTO {
        guard let id = req.parameters.get("checkItemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid check item ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> CheckItemResponseDTO {
        guard let sessionID = req.query[UUID.self, at: "sessionID"] else {
            throw Abort(.badRequest, reason: "sessionID query parameter is required")
        }
        let dto = try req.content.decode(CheckItemCreateDTO.self)
        return try await service.create(dto: dto, sessionID: sessionID, on: req.db)
    }

    func toggle(req: Request) async throws -> CheckItemResponseDTO {
        guard let id = req.parameters.get("checkItemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid check item ID")
        }
        return try await service.toggle(id: id, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("checkItemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid check item ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }
}
