
// DTOs/CheckItemDTO.swift
import Vapor

struct CheckItemCreateDTO: Content {
    let itemID: UUID
}

struct CheckItemResponseDTO: Content {
    let id: UUID
    let itemID: UUID
    let isChecked: Bool
}

extension CheckItem {
    func toDTO() -> CheckItemResponseDTO {
        CheckItemResponseDTO(
            id: self.id!,
            itemID: self.$item.id,
            isChecked: self.isChecked
        )
    }
}
