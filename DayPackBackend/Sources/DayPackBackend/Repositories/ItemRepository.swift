
import Fluent
import Vapor

protocol ItemRepositoryProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [Item]
    func find(id: UUID, on db: any Database) async throws -> Item?
    func create(_ item: Item, on db: any Database) async throws -> Item
    func update(_ item: Item, on db: any Database) async throws -> Item
    func delete(id: UUID, on db: any Database) async throws
    func findRecurring(for loadoutID: UUID, on db: any Database) async throws -> [Item]
}

struct ItemRepository: ItemRepositoryProtocol {
    func findAll(for loadoutID: UUID, on db: any Database) async throws -> [Item] {
        try await Item.query(on: db)
            .filter(\.$loadout.$id == loadoutID)
            .sort(\.$order)
            .all()
    }

    func find(id: UUID, on db: any Database) async throws -> Item? {
        try await Item.find(id, on: db)
    }

    func create(_ item: Item, on db: any Database) async throws -> Item {
        try await item.save(on: db)
        return item
    }

    func update(_ item: Item, on db: any Database) async throws -> Item {
        try await item.save(on: db)
        return item
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let item = try await Item.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await item.delete(on: db)
    }

    func findRecurring(for loadoutID: UUID, on db: any Database) async throws -> [Item] {
        try await Item.query(on: db)
            .filter(\.$loadout.$id == loadoutID)
            .filter(\.$isRecurring == true)
            .sort(\.$order)
            .all()
    }
}
