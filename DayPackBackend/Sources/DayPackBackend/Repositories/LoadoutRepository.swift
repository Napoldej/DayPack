// Repositories/LoadoutRepository.swift
import Fluent
import Vapor

protocol LoadoutRepositoryProtocol {
    func findAll(for userID: UUID, on db: any Database) async throws -> [Loadout]
    func find(id: UUID, on db: any Database) async throws -> Loadout?
    func create(_ loadout: Loadout, on db: any Database) async throws -> Loadout
    func update(_ loadout: Loadout, on db: any Database) async throws -> Loadout
    func delete(id: UUID, on db: any Database) async throws
    func deleteExpired(on db: any Database) async throws
}

struct LoadoutRepository: LoadoutRepositoryProtocol {
    func findAll(for userID: UUID, on db: any Database) async throws -> [Loadout] {
        try await Loadout.query(on: db)
            .filter(\.$user.$id == userID)
            .with(\.$items)
            .all()
    }

    func find(id: UUID, on db: any Database) async throws -> Loadout? {
        try await Loadout.query(on: db)
            .filter(\.$id == id)
            .with(\.$items)
            .first()
    }

    func create(_ loadout: Loadout, on db: any Database) async throws -> Loadout {
        try await loadout.save(on: db)
        return loadout
    }

    func update(_ loadout: Loadout, on db: any Database) async throws -> Loadout {
        try await loadout.save(on: db)
        return loadout
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let loadout = try await Loadout.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await loadout.delete(on: db)
    }
    
    func deleteExpired(on db: any Database) async throws {
            try await Loadout.query(on: db)
                .filter(\.$isTemporary == true)
                .filter(\.$expiresAt <= Date())
                .delete()
        }
}
