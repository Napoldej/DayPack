import Foundation

struct ChecklistEntry: Identifiable, Hashable, Codable {
    let id: UUID
    let itemID: UUID
    var isPacked: Bool

    init(id: UUID = UUID(), itemID: UUID, isPacked: Bool = false) {
        self.id = id
        self.itemID = itemID
        self.isPacked = isPacked
    }
}
