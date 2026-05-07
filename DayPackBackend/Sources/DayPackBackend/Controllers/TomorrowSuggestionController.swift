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
    func suggest(req: Request) async throws -> Response {
        guard let userID = req.query[UUID.self, at: "userID"] else {
            throw Abort(.badRequest, reason: "userID query parameter is required")
        }

        let result = try await service.suggest(userID: userID, on: req.db)

        // If no match return 204 No Content
        guard let loadout = result else {
            return Response(status: .noContent)
        }

        // If match found return 200 with loadout
        let response = Response(status: .ok)
        try response.content.encode(loadout)
        return response
    }
}
