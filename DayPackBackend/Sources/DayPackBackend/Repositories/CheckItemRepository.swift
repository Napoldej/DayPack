import Fluent
import Vapor

protocol CheckItemRepositoryProtocol {
    func findAll(for sessionID: UUID, on db: any Database) async throws -> [CheckItem]
    func find(id: UUID, on db: any Database) async throws -> CheckItem?
    func create(_ checkItem: CheckItem, on db: any Database) async throws -> CheckItem
    func toggle(id: UUID, on db: any Database) async throws -> CheckItem
    func delete(id: UUID, on db: any Database) async throws
}

struct CheckItemRepository: CheckItemRepositoryProtocol {
    func findAll(for sessionID: UUID, on db: any Database) async throws -> [CheckItem] {
        try await CheckItem.query(on: db)
            .filter(\.$checkSession.$id == sessionID)
            .all()
    }

    func find(id: UUID, on db: any Database) async throws -> CheckItem? {
        try await CheckItem.find(id, on: db)
    }

    func create(_ checkItem: CheckItem, on db: any Database) async throws -> CheckItem {
        try await checkItem.save(on: db)
        return checkItem
    }

    func toggle(id: UUID, on db: any Database) async throws -> CheckItem {
        guard let checkItem = try await CheckItem.find(id, on: db) else {
            throw Abort(.notFound)
        }
        checkItem.isChecked.toggle()
        try await checkItem.save(on: db)
        return checkItem
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let checkItem = try await CheckItem.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await checkItem.delete(on: db)
    }
}
