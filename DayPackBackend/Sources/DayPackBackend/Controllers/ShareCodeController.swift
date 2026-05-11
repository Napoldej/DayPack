import Fluent
import Vapor

struct ShareCodeController: RouteCollection, @unchecked Sendable {
    let service: any ShareCodeServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let shareCodes = routes.grouped("share-codes")
        shareCodes.post(use: create)
        shareCodes.group(":code") { code in
            code.get(use: preview)
            code.post("import", use: importLoadout)
        }
    }

    func create(req: Request) async throws -> ShareCodeResponseDTO {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        let dto = try req.content.decode(ShareCodeCreateDTO.self)
        return try await service.create(dto: dto, userID: userID, on: req.db)
    }

    func preview(req: Request) async throws -> ShareCodePreviewDTO {
        guard let code = req.parameters.get("code") else {
            throw Abort(.badRequest, reason: "Share code is required")
        }
        return try await service.preview(code: code, on: req.db)
    }

    func importLoadout(req: Request) async throws -> LoadoutResponseDTO {
        guard let code = req.parameters.get("code") else {
            throw Abort(.badRequest, reason: "Share code is required")
        }
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        return try await service.importLoadout(code: code, userID: userID, on: req.db)
    }
}
