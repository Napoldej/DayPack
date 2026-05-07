// Services/AuthService.swift
import Fluent
import Vapor
import JWT

protocol AuthServiceProtocol: Sendable {
    func register(dto: RegisterDTO, req: Request) async throws -> AuthResponseDTO
    func login(dto: LoginDTO, req: Request) async throws -> AuthResponseDTO
}

struct AuthService: AuthServiceProtocol, @unchecked Sendable {
    let repository: any UserRepositoryProtocol

    func register(dto: RegisterDTO, req: Request) async throws -> AuthResponseDTO {
        let existing = try await repository.findByEmail(email: dto.email, on: req.db)
        guard existing == nil else {
            throw Abort(.conflict, reason: "Email already in use")
        }

        let hashedPassword = try Bcrypt.hash(dto.password)
        let user = User(
            name: dto.name,
            email: dto.email,
            password: hashedPassword
        )
        let created = try await repository.create(user, on: req.db)
        let token = try generateToken(for: created, req: req)
        return AuthResponseDTO(token: token, user: created.toDTO())
    }

    func login(dto: LoginDTO, req: Request) async throws -> AuthResponseDTO {
        guard let user = try await repository.findByEmail(email: dto.email, on: req.db) else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        guard try Bcrypt.verify(dto.password, created: user.password) else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        let token = try generateToken(for: user, req: req)
        return AuthResponseDTO(token: token, user: user.toDTO())
    }

    private func generateToken(for user: User, req: Request) throws -> String {
        let payload = AppJWTPayload(
            subject: SubjectClaim(value: user.id!.uuidString),
            expiration: ExpirationClaim(value: Date().addingTimeInterval(60 * 60 * 24 * 7)),
            userID: user.id!
        )
        return try req.jwt.sign(payload)
    }
}
