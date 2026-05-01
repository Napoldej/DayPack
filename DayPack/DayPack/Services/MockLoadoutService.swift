import Foundation

@Observable
final class MockLoadoutService: LoadoutService {

    static let shared = MockLoadoutService()

    private(set) var items: [Item]
    private(set) var loadouts: [Loadout]
    private(set) var entries: [ChecklistEntry]

    private let stats: [DayStat]

    init() {
        let notebook    = Item(name: "Notebook",     symbol: "book.closed.fill",  tint: .green,  tag: "Always")
        let waterBottle = Item(name: "Water Bottle", symbol: "drop.fill",         tint: .orange, priority: .high, tag: "Don't forget")
        let laptop      = Item(name: "Laptop",       symbol: "laptopcomputer",    tint: .purple, tag: "Always")
        let headphones  = Item(name: "Headphones",   symbol: "headphones",        tint: .teal)
        let wallet      = Item(name: "Wallet",       symbol: "wallet.pass.fill",  tint: .orange, tag: "Always")
        let keys        = Item(name: "Keys",         symbol: "key.fill",          tint: .orange, tag: "Always")
        let proteinShake = Item(name: "Protein Shake", symbol: "drop.halffull",   tint: .red,    priority: .high, tag: "Don't forget")
        let gymShoes    = Item(name: "Gym Shoes",    symbol: "shoeprints.fill",   tint: .green)
        let towel       = Item(name: "Towel",        symbol: "square.fill",       tint: .blue,   tag: "Optional")
        let earbuds     = Item(name: "Earbuds",      symbol: "earbuds",           tint: .purple)
        let passport    = Item(name: "Passport",     symbol: "doc.text.fill",     tint: .red,    priority: .high, tag: "Don't forget")
        let charger     = Item(name: "Charger",      symbol: "powerplug.fill",    tint: .green,  tag: "Always")
        let toothbrush  = Item(name: "Toothbrush",   symbol: "mouth.fill",        tint: .blue)
        let umbrella    = Item(name: "Umbrella",     symbol: "umbrella.fill",     tint: .blue,   tag: "Optional")

        let allItems: [Item] = [
            notebook, waterBottle, laptop, headphones, wallet, keys,
            proteinShake, gymShoes, towel, earbuds, passport, charger,
            toothbrush, umbrella,
        ]

        let schoolDay = Loadout(
            name: "School Day",
            symbol: "book.closed.fill",
            tint: .orange,
            schedule: "Mon · Wed · Fri",
            itemIDs: [notebook.id, waterBottle.id, laptop.id, headphones.id, wallet.id, keys.id]
        )
        let gymDay = Loadout(
            name: "Gym Day",
            symbol: "dumbbell.fill",
            tint: .purple,
            schedule: "Tue · Thu · Sat",
            itemIDs: [proteinShake.id, gymShoes.id, towel.id, earbuds.id, waterBottle.id]
        )
        let travel = Loadout(
            name: "Travel",
            symbol: "paperplane.fill",
            tint: .teal,
            schedule: "Manual",
            itemIDs: [passport.id, charger.id, toothbrush.id, umbrella.id, headphones.id, wallet.id, keys.id]
        )

        self.items = allItems
        self.loadouts = [schoolDay, gymDay, travel]

        var seedEntries: [ChecklistEntry] = []
        for loadout in [schoolDay, gymDay, travel] {
            for (i, itemID) in loadout.itemIDs.enumerated() {
                let isPacked = (loadout.id == schoolDay.id) ? (i < 3) : false
                seedEntries.append(ChecklistEntry(itemID: itemID, isPacked: isPacked))
            }
        }
        self.entries = seedEntries

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var seedStats: [DayStat] = []
        for offset in 0..<30 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let pattern = [1.0, 1.0, 0.83, 1.0, 0.5, 1.0, 1.0, 1.0, 0.66, 1.0,
                           1.0, 0.83, 1.0, 0.0, 1.0, 1.0, 1.0, 0.83, 1.0, 1.0,
                           0.66, 1.0, 1.0, 1.0, 0.83, 1.0, 0.0, 1.0, 1.0, 1.0]
            seedStats.append(DayStat(date: date, completion: pattern[offset]))
        }
        self.stats = seedStats
    }

    func todaysLoadout() -> Loadout? {
        loadouts.first
    }

    func allLoadouts() -> [Loadout] {
        loadouts
    }

    func items(in loadout: Loadout) -> [Item] {
        loadout.itemIDs.compactMap { id in items.first(where: { $0.id == id }) }
    }

    func entries(for loadout: Loadout) -> [ChecklistEntry] {
        loadout.itemIDs.compactMap { itemID in
            entries.first(where: { $0.itemID == itemID })
        }
    }

    func togglePacked(entryID: UUID) {
        guard let idx = entries.firstIndex(where: { $0.id == entryID }) else { return }
        entries[idx].isPacked.toggle()
    }

    func recentDayStats(days: Int) -> [DayStat] {
        Array(stats.prefix(days)).reversed()
    }

    func currentStreak() -> Int {
        var streak = 0
        for stat in stats {
            if stat.completion >= 0.999 { streak += 1 } else { break }
        }
        return streak
    }
}
