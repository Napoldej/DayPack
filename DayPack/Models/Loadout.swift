import Foundation

struct Loadout: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var symbol: String
    var tint: ItemTint
    var schedule: String
    var itemIDs: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        itemIDs: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tint = tint
        self.schedule = schedule
        self.itemIDs = itemIDs
    }
}
