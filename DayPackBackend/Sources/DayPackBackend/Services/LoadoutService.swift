// Services/LoadoutService.swift
import Fluent
import Vapor

protocol LoadoutServiceProtocol {
    func findAll(for userID: UUID, on db: any Database) async throws -> [LoadoutResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> LoadoutResponseDTO
    func create(dto: LoadoutCreateDTO, userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO
    func update(id: UUID, dto: LoadoutUpdateDTO, on db: any Database) async throws -> LoadoutResponseDTO
    func delete(id: UUID, on db: any Database) async throws
}

struct LoadoutService: LoadoutServiceProtocol {
    let repository: any LoadoutRepositoryProtocol

    func findAll(for userID: UUID, on db: any Database) async throws -> [LoadoutResponseDTO] {
        let loadouts = try await repository.findAll(for: userID, on: db)
        return loadouts.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> LoadoutResponseDTO {
        guard let loadout = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Loadout not found")
        }
        return loadout.toDTO()
    }

    func create(dto: LoadoutCreateDTO, userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO {
        let loadout = Loadout(
            name: dto.name,
            icon: dto.icon,
            isShared: dto.isShared,
            userID: userID
        )
        let created = try await repository.create(loadout, on: db)
        return created.toDTO()
    }

    func update(id: UUID, dto: LoadoutUpdateDTO, on db: any Database) async throws -> LoadoutResponseDTO {
        guard let loadout = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Loadout not found")
        }
        if let name = dto.name { loadout.name = name }
        if let icon = dto.icon { loadout.icon = icon }
        if let isShared = dto.isShared { loadout.isShared = isShared }

        let updated = try await repository.update(loadout, on: db)
        return updated.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Loadout not found")
        }
        try await repository.delete(id: id, on: db)
    }
}
