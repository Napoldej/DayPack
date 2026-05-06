import SwiftUI

@Observable
final class TodayViewModel {
    var loadout: Loadout?
    var items: [Item] = []
    var entries: [ChecklistEntry] = []

    private let service: any LoadoutService

    init(service: any LoadoutService) {
        self.service = service
        refresh()
    }

    func refresh() {
        loadout = service.todaysLoadout()
        if let loadout {
            items = service.items(in: loadout)
            entries = service.entries(for: loadout)
        }
    }

    func entry(for item: Item) -> ChecklistEntry? {
        entries.first(where: { $0.itemID == item.id })
    }

    func togglePacked(for item: Item) {
        guard let entry = entry(for: item) else { return }
        service.togglePacked(entryID: entry.id)
        refresh()
    }

    var packedCount: Int {
        entries.filter { $0.isPacked }.count
    }

    var totalCount: Int {
        entries.count
    }

    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(packedCount) / Double(totalCount)
    }
}
