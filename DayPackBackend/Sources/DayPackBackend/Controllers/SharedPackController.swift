
// Controllers/SharedPackController.swiftimport Fluent
import Vapor

struct SharedPackController: RouteCollection, @unchecked Sendable {
    let service: any SharedPackServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let sharedPacks = routes.grouped("shared-packs")
        sharedPacks.get("sent", use: sentByUser)
        sharedPacks.get("received", use: receivedByUser)
        sharedPacks.post(use: create)
        sharedPacks.group(":sharedPackID") { pack in
            pack.get(use: show)
            pack.delete(use: delete)
        }
    }

    func sentByUser(req: Request) async throws -> [SharedPackResponseDTO] {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        return try await service.findAllSharedByUser(userID: userID, on: req.db)
    }

    func receivedByUser(req: Request) async throws -> [SharedPackResponseDTO] {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }
        return try await service.findAllSharedWithUser(userID: userID, on: req.db)
    }

    func show(req: Request) async throws -> SharedPackResponseDTO {
        guard let id = req.parameters.get("sharedPackID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shared pack ID")
        }
        return try await service.find(id: id, on: req.db)
    }

    func create(req: Request) async throws -> SharedPackResponseDTO {
        guard let sharedByUserID = req.query[UUID.self, at: "sharedByUserID"] else {
            throw Abort(.badRequest, reason: "sharedByUserID query parameter is required")
        }
        let dto = try req.content.decode(SharedPackCreateDTO.self)
        return try await service.create(dto: dto, sharedByUserID: sharedByUserID, on: req.db)
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("sharedPackID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid shared pack ID")
        }
        try await service.delete(id: id, on: req.db)
        return .noContent
    }
}
