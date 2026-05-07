
// DTOs/LoadoutDTO.swift
import Vapor

struct LoadoutCreateDTO: Content {
    let name: String
    let icon: String?
    let isShared: Bool
}

struct LoadoutUpdateDTO: Content {
    let name: String?
    let icon: String?
    let isShared: Bool?
}

struct LoadoutResponseDTO: Content {
    let id: UUID
    let name: String
    let icon: String?
    let isShared: Bool
    let items: [ItemResponseDTO]
}

extension Loadout {
    func toDTO() -> LoadoutResponseDTO {
        LoadoutResponseDTO(
            id: self.id!,
            name: self.name,
            icon: self.icon,
            isShared: self.isShared,
            items: self.items.map { $0.toDTO() }
        )
    }
}
