import Fluent
import Vapor

protocol SharedPackServiceProtocol {
    func findAllSharedByUser(userID: UUID, on db: any Database) async throws -> [SharedPackResponseDTO]
    func findAllSharedWithUser(userID: UUID, on db: any Database) async throws -> [SharedPackResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> SharedPackResponseDTO
    func create(dto: SharedPackCreateDTO, sharedByUserID: UUID, on db: any Database) async throws -> SharedPackResponseDTO
    func delete(id: UUID, on db: any Database) async throws
}

struct SharedPackService: SharedPackServiceProtocol {
    let repository: any SharedPackRepositoryProtocol

    func findAllSharedByUser(userID: UUID, on db: any Database) async throws -> [SharedPackResponseDTO] {
        let packs = try await repository.findAllSharedByUser(userID: userID, on: db)
        return packs.map { $0.toDTO() }
    }

    func findAllSharedWithUser(userID: UUID, on db: any Database) async throws -> [SharedPackResponseDTO] {
        let packs = try await repository.findAllSharedWithUser(userID: userID, on: db)
        return packs.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> SharedPackResponseDTO {
        guard let pack = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Shared pack not found")
        }
        return pack.toDTO()
    }

    func create(dto: SharedPackCreateDTO, sharedByUserID: UUID, on db: any Database) async throws -> SharedPackResponseDTO {
        guard dto.sharedWithUserID != sharedByUserID else {
            throw Abort(.badRequest, reason: "Cannot share a pack with yourself")
        }
        let pack = SharedPack(
            loadoutID: dto.loadoutID,
            sharedByUserID: sharedByUserID,
            sharedWithUserID: dto.sharedWithUserID
        )
        let created = try await repository.create(pack, on: db)
        return created.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Shared pack not found")
        }
        try await repository.delete(id: id, on: db)
    }
}
