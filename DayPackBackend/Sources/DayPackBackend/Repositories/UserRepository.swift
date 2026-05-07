// Repositories/UserRepository.swift
import Fluent
import Vapor

protocol UserRepositoryProtocol {
    func findAll(on db: any Database) async throws -> [User]
    func find(id: UUID, on db: any Database) async throws -> User?
    func findByEmail(email: String, on db: any Database) async throws -> User?
    func create(_ user: User, on db: any Database) async throws -> User
    func update(_ user: User, on db: any Database) async throws -> User
    func delete(id: UUID, on db: any Database) async throws
}

struct UserRepository: UserRepositoryProtocol {
    func findAll(on db: any Database) async throws -> [User] {
        try await User.query(on: db).all()
    }

    func find(id: UUID, on db: any Database) async throws -> User? {
        try await User.find(id, on: db)
    }

    func findByEmail(email: String, on db: any Database) async throws -> User? {
        try await User.query(on: db)
            .filter(\.$email == email)
            .first()
    }

    func create(_ user: User, on db: any Database) async throws -> User {
        try await user.save(on: db)
        return user
    }

    func update(_ user: User, on db: any Database) async throws -> User {
        try await user.save(on: db)
        return user
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let user = try await User.find(id, on: db) else {
            throw Abort(.notFound)
        }
        try await user.delete(on: db)
    }
}
