// DTOs/CheckSessionDTO.swift
import Vapor

struct CheckSessionCreateDTO: Content {
    let loadoutID: UUID
}

struct CheckSessionResponseDTO: Content {
    let id: UUID
    let loadoutID: UUID
    let startedAt: Date
    let completedAt: Date?
    let checkItems: [CheckItemResponseDTO]
}

extension CheckSession {
    func toDTO() -> CheckSessionResponseDTO {
        CheckSessionResponseDTO(
            id: self.id!,
            loadoutID: self.$loadout.id,
            startedAt: self.startedAt,
            completedAt: self.completedAt,
            checkItems: self.checkItems.map { $0.toDTO() }
        )
    }
}
