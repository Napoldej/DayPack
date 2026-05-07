
import Fluent
import Vapor

protocol CheckItemServiceProtocol {
    func findAll(for sessionID: UUID, on db: any Database) async throws -> [CheckItemResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> CheckItemResponseDTO
    func create(dto: CheckItemCreateDTO, sessionID: UUID, on db: any Database) async throws -> CheckItemResponseDTO
    func toggle(id: UUID, on db: any Database) async throws -> CheckItemResponseDTO
    func delete(id: UUID, on db: any Database) async throws
}

struct CheckItemService: CheckItemServiceProtocol {
    let repository: any CheckItemRepositoryProtocol

    func findAll(for sessionID: UUID, on db: any Database) async throws -> [CheckItemResponseDTO] {
        let checkItems = try await repository.findAll(for: sessionID, on: db)
        return checkItems.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> CheckItemResponseDTO {
        guard let checkItem = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check item not found")
        }
        return checkItem.toDTO()
    }

    func create(dto: CheckItemCreateDTO, sessionID: UUID, on db: any Database) async throws -> CheckItemResponseDTO {
        let checkItem = CheckItem(
            checkSessionID: sessionID,
            itemID: dto.itemID
        )
        let created = try await repository.create(checkItem, on: db)
        return created.toDTO()
    }

    func toggle(id: UUID, on db: any Database) async throws -> CheckItemResponseDTO {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check item not found")
        }
        let toggled = try await repository.toggle(id: id, on: db)
        return toggled.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "Check item not found")
        }
        try await repository.delete(id: id, on: db)
    }
}
