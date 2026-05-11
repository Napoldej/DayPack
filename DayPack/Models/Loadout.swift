import Foundation

struct Loadout: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var symbol: String
    var tint: ItemTint
    var schedule: String
    var itemIDs: [UUID]
    var scheduledDays: [Int]
    var isTemporary: Bool
    var expiresAt: Date?
    var alertTime: String?
    var returnAlertTime: String?
    var isSuggestedForTomorrow: Bool

    init(
        id: UUID = UUID(),
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        itemIDs: [UUID] = [],
        scheduledDays: [Int] = [],
        isTemporary: Bool = false,
        expiresAt: Date? = nil,
        alertTime: String? = nil,
        returnAlertTime: String? = nil,
        isSuggestedForTomorrow: Bool = false
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tint = tint
        self.schedule = schedule
        self.itemIDs = itemIDs
        self.scheduledDays = scheduledDays
        self.isTemporary = isTemporary
        self.expiresAt = expiresAt
        self.alertTime = alertTime
        self.returnAlertTime = returnAlertTime
        self.isSuggestedForTomorrow = isSuggestedForTomorrow
    }
}
