// Repositories/CheckSessionRepository.swift
import Fluent
import Vapor

protocol CheckSessionRepositoryProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [CheckSession]
    func find(id: UUID, on db: any Database) async throws -> CheckSession?
    func create(_ session: CheckSession, on db: any Database) async throws -> CheckSession
    func complete(id: UUID, on db: any Database) async throws -> CheckSession
    func delete(id: UUID, on db: any Database) async throws
}

struct CheckSessionRepository: CheckSessionRepositoryProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [CheckSession] {
        try await CheckSession.query(on: db)
            .filter(\.$loadout.$id == loadoutID)
            .with(\.$checkItems)
            .sort(\.$startedAt, .descending)
            .all()
    }

    func find(id: UUID, on db: any Database) async throws -> CheckSession? {
        try await CheckSession.query(on: db)
            .filter(\.$id == id)
            .with(\.$checkItems)
            .first()
    }

    func create(_ session: CheckSession, on db: any Database) async throws -> CheckSession {
        try await session.save(on: db)
        return try await findLoaded(id: try session.requireID(), on: db)
    }

    func complete(id: UUID, on db: any Database) async throws -> CheckSession {
        guard let session = try await CheckSession.find(id, on: db) else {
            throw Abort(.notFound)
        }
        session.completedAt = Date()
        try await session.save(on: db)
        return try await findLoaded(id: id, on: db)
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let session = try await CheckSession.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await session.delete(on: db)
    }

    private func findLoaded(id: UUID, on db: any Database) async throws -> CheckSession {
        guard let session = try await find(id: id, on: db) else {
            throw Abort(.notFound)
        }
        return session
    }
}
