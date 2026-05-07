// Services/CheckSessionService.swift
import Fluent
import Vapor

protocol CheckSessionServiceProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [CheckSessionResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> CheckSessionResponseDTO
    func create(dto: CheckSessionCreateDTO, on db: any Database) async throws -> CheckSessionResponseDTO
    func complete(id: UUID, on db: any Database) async throws -> CheckSessionResponseDTO
    func delete(id: UUID, on db: any Database) async throws
}

struct CheckSessionService: CheckSessionServiceProtocol {
    let repository: any CheckSessionRepositoryProtocol

    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [CheckSessionResponseDTO] {
        let sessions = try await repository.findAll(for: loadoutID, on: db)
        return sessions.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> CheckSessionResponseDTO {
        guard let session = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check session not found")
        }
        return session.toDTO()
    }

    func create(dto: CheckSessionCreateDTO, on db: any Database) async throws -> CheckSessionResponseDTO {
        let session = CheckSession(loadoutID: dto.loadoutID)
        let created = try await repository.create(session, on: db)
        return created.toDTO()
    }

    func complete(id: UUID, on db: any Database) async throws -> CheckSessionResponseDTO {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check session not found")
        }
        let completed = try await repository.complete(id: id, on: db)
        return completed.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check session not found")
        }
        try await repository.delete(id: id, on: db)
    }
}
