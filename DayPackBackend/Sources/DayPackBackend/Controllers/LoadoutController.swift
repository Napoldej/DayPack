// Controllers/LoadoutController.swift
import Fluent
import Vapor

struct LoadoutController: RouteCollection, @unchecked Sendable {
    let service: any LoadoutServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let loadouts = routes.grouped("loadouts")
        loadouts.get(use: index)
        loadouts.post(use: create)
        loadouts.group(":loadoutID") { loadout in
            loadout.get(use: show)
            loadout.put(use: update)
            loadout.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [LoadoutResponseDTO] {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        return try await service.findAll(for: userID, on: req.db)
    }

    func show(req: Request) async throws -> LoadoutResponseDTO {
        guard let id = req.parameters.get("loadoutID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid loadout ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> LoadoutResponseDTO {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        let dto = try req.content.decode(LoadoutCreateDTO.self)
        return try await service.create(dto: dto, userID: userID, on: req.db)
    }

    func update(req: Request) async throws -> LoadoutResponseDTO {
        guard let id = req.parameters.get("loadoutID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid loadout ID")
        }
        let dto = try req.content.decode(LoadoutUpdateDTO.self)
        return try await service.update(id: id, dto: dto, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("loadoutID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid loadout ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }
}
