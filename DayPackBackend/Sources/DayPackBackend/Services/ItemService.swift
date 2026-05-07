
// Services/ItemService.swift
import Fluent
import Vapor

protocol ItemServiceProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [ItemResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> ItemResponseDTO
    func create(dto: ItemCreateDTO, loadoutID: UUID, on db: any Database) async throws -> ItemResponseDTO
    func update(id: UUID, dto: ItemUpdateDTO, on db: any Database) async throws -> ItemResponseDTO
    func delete(id: UUID, on db: any Database) async throws
    func findRecurring(for loadoutID: UUID, on db: any Database) async throws -> [ItemResponseDTO]
}

struct ItemService: ItemServiceProtocol {
    let repository: any ItemRepositoryProtocol

    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [ItemResponseDTO] {
        let items = try await repository.findAll(for: loadoutID, on: db)
        return items.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> ItemResponseDTO {
        guard let item = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Item not found")
        }
        return item.toDTO()
    }

    func create(dto: ItemCreateDTO, loadoutID: UUID, on db: any Database) async throws -> ItemResponseDTO {
        let item = Item(
            name: dto.name,
            isRecurring: dto.isRecurring,
            order: dto.order,
            loadoutID: loadoutID
        )
        let created = try await repository.create(item, on: db)
        return created.toDTO()
    }

    func update(id: UUID, dto: ItemUpdateDTO, on db: any Database) async throws -> ItemResponseDTO {
        guard let item = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Item not found")
        }
        if let name = dto.name { item.name = name }
        if let isRecurring = dto.isRecurring { item.isRecurring = isRecurring }
        if let order = dto.order { item.order = order }

        let updated = try await repository.update(item, on: db)
        return updated.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Item not found")
        }
        try await repository.delete(id: id, on: db)
    }

    func findRecurring(for loadoutID: UUID, on db: any Database) async throws -> [ItemResponseDTO] {
        let items = try await repository.findRecurring(for: loadoutID, on: db)
        return items.map { $0.toDTO() }
    }
}
