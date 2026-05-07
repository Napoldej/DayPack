
import Fluent
import Vapor

protocol UserServiceProtocol {
    func findAll(on db: any Database) async throws -> [UserResponseDTO]
    func find(id: UUID, on db: any Database) async throws -> UserResponseDTO
    func findByEmail(email: String, on db: any Database) async throws -> UserResponseDTO
    func create(dto: UserCreateDTO, on db: any Database) async throws -> UserResponseDTO
    func update(id: UUID, dto: UserUpdateDTO, on db: any Database) async throws -> UserResponseDTO
    func delete(id: UUID, on db: any Database) async throws
}

struct UserService: UserServiceProtocol {
    let repository: any UserRepositoryProtocol

    func findAll(on db: any Database) async throws -> [UserResponseDTO] {
        let users = try await repository.findAll(on: db)
        return users.map { $0.toDTO() }
    }

    func find(id: UUID, on db: any Database) async throws -> UserResponseDTO {
        guard let user = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user.toDTO()
    }

    func findByEmail(email: String, on db: any Database) async throws -> UserResponseDTO {
        guard let user = try await repository.findByEmail(email: email, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user.toDTO()
    }

    func create(dto: UserCreateDTO, on db: any Database) async throws -> UserResponseDTO {
        let existing = try await repository.findByEmail(email: dto.email, on: db)
        guard existing == nil else {
            throw Abort(.conflict, reason: "Email already in use")
        }
        let user = User(
            name: dto.name,
            email: dto.email,
            password: dto.password
        )
        let created = try await repository.create(user, on: db)
        return created.toDTO()
    }

    func update(id: UUID, dto: UserUpdateDTO, on db: any Database) async throws -> UserResponseDTO {
        guard let user = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        if let name = dto.name { user.name = name }
        if let email = dto.email { user.email = email }
        if let password = dto.password { user.password = password }

        let updated = try await repository.update(user, on: db)
        return updated.toDTO()
    }

    func delete(id: UUID, on db: any Database) async throws {
        guard let _ = try await repository.find(id: id, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        try await repository.delete(id: id, on: db)
    }
}
