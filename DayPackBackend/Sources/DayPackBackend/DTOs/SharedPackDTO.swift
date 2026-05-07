
// DTOs/SharedPackDTO.swift
import Vapor

struct SharedPackCreateDTO: Content {
    let loadoutID: UUID
    let sharedWithUserID: UUID
}

struct SharedPackResponseDTO: Content {
    let id: UUID
    let loadoutID: UUID
    let sharedByUserID: UUID
    let sharedWithUserID: UUID
}

extension SharedPack {
    func toDTO() -> SharedPackResponseDTO {
        SharedPackResponseDTO(
            id: self.id!,
            loadoutID: self.$loadout.id,
            sharedByUserID: self.$sharedByUser.id,
            sharedWithUserID: self.$sharedWithUser.id
        )
    }
}
