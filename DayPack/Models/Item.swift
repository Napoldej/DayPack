import SwiftUI

enum Priority: String, CaseIterable, Codable, Hashable {
    case low, normal, high
}

enum ItemTint: String, CaseIterable, Codable, Hashable {
    case green, orange, red, blue, purple, teal

    var foreground: Color {
        switch self {
        case .green:  return Color.dpGreen
        case .orange: return Color.dpOrangeDeep
        case .red:    return Color.dpRed
        case .blue:   return Color(hex: 0x3478F6)
        case .purple: return Color(hex: 0x7C5BFF)
        case .teal:   return Color(hex: 0x19B5A4)
        }
    }

    var background: Color {
        switch self {
        case .green:  return Color.dpGreenSoft
        case .orange: return Color.dpOrangeSoft
        case .red:    return Color.dpRedSoft
        case .blue:   return Color(hex: 0x3478F6, alpha: 0.12)
        case .purple: return Color(hex: 0x7C5BFF, alpha: 0.12)
        case .teal:   return Color(hex: 0x19B5A4, alpha: 0.12)
        }
    }
}

struct Item: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var symbol: String
    var tint: ItemTint
    var priority: Priority
    var tag: String?
    var order: Int

    init(
        id: UUID = UUID(),
        name: String,
        symbol: String,
        tint: ItemTint = .orange,
        priority: Priority = .normal,
        tag: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tint = tint
        self.priority = priority
        self.tag = tag
        self.order = order
    }
}
