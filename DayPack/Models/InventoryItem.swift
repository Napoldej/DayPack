import Foundation

struct InventoryItem: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var symbol: String
    var tint: ItemTint

    init(
        id: UUID = UUID(),
        name: String,
        symbol: String,
        tint: ItemTint = .orange
    ) {
        self.id = id
        self.name = name
        self.symbol = symbol
        self.tint = tint
    }
}

enum SymbolCatalog {
    static let common: [String] = [
        // Bags & containers
        "backpack.fill", "briefcase.fill", "suitcase.fill", "shippingbox.fill",
        // School & work
        "book.closed.fill", "laptopcomputer", "doc.text.fill", "pencil", "pencil.and.ruler.fill",
        // Tech & charging
        "iphone", "ipad", "headphones", "earbuds", "powerplug.fill", "battery.100",
        // Personal essentials
        "wallet.pass.fill", "key.fill", "creditcard.fill", "eyeglasses",
        // Sports & fitness
        "dumbbell.fill", "shoeprints.fill", "figure.run", "figure.walk",
        // Travel
        "paperplane.fill", "airplane", "car.fill", "bicycle",
        // Drink & food
        "drop.fill", "drop.halffull", "takeoutbag.and.cup.and.straw.fill", "fork.knife",
        // Hygiene
        "mouth.fill", "comb.fill", "scissors",
        // Weather
        "umbrella.fill", "sun.max.fill", "cloud.rain.fill", "snowflake",
        // Misc
        "gift.fill", "heart.fill", "star.fill", "sparkles", "leaf.fill", "pawprint.fill",
        "clock.fill", "bell.fill", "calendar",
    ]
}
