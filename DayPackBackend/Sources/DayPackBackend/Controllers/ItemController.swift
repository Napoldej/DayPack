// Controllers/ItemController.swift
import Fluent
import Vapor

struct ItemController: RouteCollection, @unchecked Sendable {
    let service: any ItemServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let items = routes.grouped("items")
        items.get(use: index)
        items.post(use: create)
        items.get("recurring", use: recurring)
        items.group(":itemID") { item in
            item.get(use: show)
            item.put(use: update)
            item.delete(use: delete)
        }
    }

    func index(req: Request) async throws -> [ItemResponseDTO] {
        guard let loadoutID = req.query[UUID.self, at: "loadoutID"] else {
            throw Abort(.badRequest, reason: "loadoutID query parameter is required")
        }
        return try await service.findAll(for: loadoutID, on: req.db)
    }

    func show(req: Request) async throws -> ItemResponseDTO {
        guard let id = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid item ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> ItemResponseDTO {
        guard let loadoutID = req.query[UUID.self, at: "loadoutID"] else {
            throw Abort(.badRequest, reason: "loadoutID query parameter is required")
        }
        let dto = try req.content.decode(ItemCreateDTO.self)
        return try await service.create(dto: dto, loadoutID: loadoutID, on: req.db)
    }

    func update(req: Request) async throws -> ItemResponseDTO {
        guard let id = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid item ID")
        }
        let dto = try req.content.decode(ItemUpdateDTO.self)
        return try await service.update(id: id, dto: dto, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("itemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid item ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }

    func recurring(req: Request) async throws -> [ItemResponseDTO] {
        guard let loadoutID = req.query[UUID.self, at: "loadoutID"] else {
            throw Abort(.badRequest, reason: "loadoutID query parameter is required")
        }
        return try await service.findRecurring(for: loadoutID, on: req.db)
    }
}
