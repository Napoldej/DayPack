import Fluent
import Vapor

protocol ShareCodeRepositoryProtocol {
    func find(code: String, on db: any Database) async throws -> ShareCode?
    func create(_ shareCode: ShareCode, on db: any Database) async throws -> ShareCode
}

struct ShareCodeRepository: ShareCodeRepositoryProtocol {
    func find(code: String, on db: any Database) async throws -> ShareCode? {
        try await ShareCode.query(on: db)
            .filter(\.$code == code.uppercased())
            .first()
    }

    func create(_ shareCode: ShareCode, on db: any Database) async throws -> ShareCode {
        try await shareCode.save(on: db)
        return shareCode
    }
}
