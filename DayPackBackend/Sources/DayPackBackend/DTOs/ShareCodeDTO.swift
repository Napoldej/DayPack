import Vapor
import Foundation

struct ShareCodeCreateDTO: Content {
    let loadoutID: UUID
}

struct ShareCodeResponseDTO: Content {
    let id: UUID
    let code: String
    let loadoutID: UUID
    let createdByUserID: UUID
    let createdAt: Date?
}

struct ShareCodePreviewDTO: Content {
    let code: String
    let loadout: LoadoutResponseDTO
}

extension ShareCode {
    func toDTO() throws -> ShareCodeResponseDTO {
        ShareCodeResponseDTO(
            id: try self.requireID(),
            code: self.code,
            loadoutID: self.$loadout.id,
            createdByUserID: self.$createdByUser.id,
            createdAt: self.createdAt
        )
    }
}
