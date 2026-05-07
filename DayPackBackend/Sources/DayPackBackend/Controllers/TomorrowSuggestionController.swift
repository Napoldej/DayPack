// Controllers/TomorrowSuggestionController.swift
import Fluent
import Vapor

struct TomorrowSuggestionController: RouteCollection, @unchecked Sendable {
    let service: any TomorrowSuggestionServiceProtocol

    func boot(routes: any RoutesBuilder) throws {
        let loadouts = routes.grouped("loadouts")
        loadouts.get("tomorrow", use: suggest)
    }

    // GET /loadouts/tomorrow?userID=xxx
    func suggest(req: Request) async throws -> TomorrowSuggestionResponseDTO {
            guard let userID = req.query[UUID.self, at: "userID"] else {
                throw Abort(.badRequest, reason: "userID query parameter is required")
            }
            return try await service.suggest(userID: userID, on: req.db)
        }
}
