// DTOs/LoadoutDTO.swift
import Vapor
import Foundation

struct LoadoutCreateDTO: Content {
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?    // ← add this
}

struct LoadoutUpdateDTO: Content {
    let name: String?
    let icon: String?
    let isShared: Bool?
    let scheduledDays: [Int]?
    let isTemporary: Bool?
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?    // ← add this
}

struct LoadoutResponseDTO: Content {
    let id: UUID
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?    // ← add this
    let items: [ItemResponseDTO]
}

extension Loadout {
    func toDTO() -> LoadoutResponseDTO {
        LoadoutResponseDTO(
            id: self.id!,
            name: self.name,
            icon: self.icon,
            isShared: self.isShared,
            scheduledDays: self.scheduledDays,
            isTemporary: self.isTemporary,
            expiresAt: self.expiresAt,
            alertTime: self.alertTime,
            returnAlertTime: self.returnAlertTime,  // ← add this
            items: self.items.map { $0.toDTO() }
        )
    }
}
