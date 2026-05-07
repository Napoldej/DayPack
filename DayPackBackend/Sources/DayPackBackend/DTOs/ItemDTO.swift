
// DTOs/ItemDTO.swift
import Vapor

struct ItemCreateDTO: Content {
    let name: String
    let isRecurring: Bool
    let order: Int
}

struct ItemUpdateDTO: Content {
    let name: String?
    let isRecurring: Bool?
    let order: Int?
}

struct ItemResponseDTO: Content {
    let id: UUID
    let name: String
    let isRecurring: Bool
    let order: Int
}

extension Item {
    func toDTO() -> ItemResponseDTO {
        ItemResponseDTO(
            id: self.id!,
            name: self.name,
            isRecurring: self.isRecurring,
            order: self.order
        )
    }
}
