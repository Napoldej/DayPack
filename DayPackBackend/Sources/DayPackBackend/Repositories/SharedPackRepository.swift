import Fluent
import Vapor

protocol SharedPackRepositoryProtocol {
    func findAllSharedByUser(userID: UUID, on db: any Database) async throws -> [SharedPack]
    func findAllSharedWithUser(userID: UUID, on db: any Database) async throws -> [SharedPack]
    func find(id: UUID, on db: any Database) async throws -> SharedPack?
    func create(_ sharedPack: SharedPack, on db: any Database) async throws -> SharedPack
    func delete(id: UUID, on db: any Database) async throws
}

struct SharedPackRepository: SharedPackRepositoryProtocol {
    func findAllSharedByUser(userID: UUID, on db: any Database) async throws -> [SharedPack] {
        try await SharedPack.query(on: db)
            .filter(\.$sharedByUser.$id == userID)
            .all()
    }

    func findAllSharedWithUser(userID: UUID, on db: any Database) async throws -> [SharedPack] {
        try await SharedPack.query(on: db)
            .filter(\.$sharedWithUser.$id == userID)
            .all()
    }

    func find(id: UUID, on db: any Database) async throws -> SharedPack? {
        try await SharedPack.find(id, on: db)
    }

    func create(_ sharedPack: SharedPack, on db: any Database) async throws -> SharedPack {
        try await sharedPack.save(on: db)
        return sharedPack
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let sharedPack = try await SharedPack.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await sharedPack.delete(on: db)
    }
}
