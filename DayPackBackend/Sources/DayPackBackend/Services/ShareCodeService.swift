import Fluent
import Vapor

protocol ShareCodeServiceProtocol {
    func create(dto: ShareCodeCreateDTO, userID: UUID, on db: any Database) async throws -> ShareCodeResponseDTO
    func preview(code: String, on db: any Database) async throws -> ShareCodePreviewDTO
    func importLoadout(code: String, userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO
}

struct ShareCodeService: ShareCodeServiceProtocol {
    let repository: any ShareCodeRepositoryProtocol

    func create(dto: ShareCodeCreateDTO, userID: UUID, on db: any Database) async throws -> ShareCodeResponseDTO {
        guard let loadout = try await loadout(id: dto.loadoutID, on: db) else {
            throw Abort(.notFound, reason: "Loadout not found")
        }
        guard loadout.$user.id == userID else {
            throw Abort(.forbidden, reason: "You can only share your own loadouts")
        }

        let shareCode = ShareCode(
            code: try await uniqueCode(on: db),
            loadoutID: dto.loadoutID,
            createdByUserID: userID
        )
        return try await repository.create(shareCode, on: db).toDTO()
    }

    func preview(code: String, on db: any Database) async throws -> ShareCodePreviewDTO {
        let shareCode = try await requireShareCode(code: code, on: db)
        guard let loadout = try await loadout(id: shareCode.$loadout.id, on: db) else {
            throw Abort(.notFound, reason: "Shared loadout not found")
        }
        return ShareCodePreviewDTO(code: shareCode.code, loadout: loadout.toDTO())
    }

    func importLoadout(code: String, userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO {
        let shareCode = try await requireShareCode(code: code, on: db)
        guard let source = try await loadout(id: shareCode.$loadout.id, on: db) else {
            throw Abort(.notFound, reason: "Shared loadout not found")
        }

        let copy = Loadout(
            name: source.name,
            icon: source.icon,
            isShared: false,
            scheduledDays: source.scheduledDays,
            isTemporary: false,
            expiresAt: nil,
            alertTime: source.alertTime,
            returnAlertTime: source.returnAlertTime,
            userID: userID
        )
        try await copy.save(on: db)
        let copyID = try copy.requireID()

        for item in source.items {
            let itemCopy = Item(
                name: item.name,
                isRecurring: item.isRecurring,
                order: item.order,
                loadoutID: copyID
            )
            try await itemCopy.save(on: db)
        }

        guard let reloaded = try await loadout(id: copyID, on: db) else {
            throw Abort(.internalServerError, reason: "Imported loadout could not be loaded")
        }
        return reloaded.toDTO()
    }

    private func requireShareCode(code: String, on db: any Database) async throws -> ShareCode {
        guard let shareCode = try await repository.find(code: code.normalizedShareCode, on: db) else {
            throw Abort(.notFound, reason: "Share code not found")
        }
        return shareCode
    }

    private func loadout(id: UUID, on db: any Database) async throws -> Loadout? {
        try await Loadout.query(on: db)
            .filter(\.$id == id)
            .with(\.$items)
            .first()
    }

    private func uniqueCode(on db: any Database) async throws -> String {
        for _ in 0..<8 {
            let code = Self.makeCode()
            if try await repository.find(code: code, on: db) == nil {
                return code
            }
        }
        throw Abort(.internalServerError, reason: "Could not generate share code")
    }

    private static func makeCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let suffix = String((0..<4).compactMap { _ in alphabet.randomElement() })
        return "PACK-\(suffix)"
    }
}

private extension String {
    var normalizedShareCode: String {
        trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
}
