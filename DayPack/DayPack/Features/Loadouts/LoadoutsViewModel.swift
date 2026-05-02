import SwiftUI

@Observable
final class LoadoutsViewModel {
    var loadouts: [Loadout] = []
    var searchText: String = ""

    private let service: any LoadoutService

    init(service: any LoadoutService) {
        self.service = service
        refresh()
    }

    func refresh() {
        loadouts = service.allLoadouts()
    }

    func itemCount(for loadout: Loadout) -> Int {
        service.items(in: loadout).count
    }

    func setToday(_ loadout: Loadout) {
        service.setTodaysLoadout(id: loadout.id)
        refresh()
    }

    @discardableResult
    func createLoadout(name: String, symbol: String, tint: ItemTint, schedule: String, items: [Item]) -> Loadout {
        let loadout = service.createLoadout(
            name: name,
            symbol: symbol,
            tint: tint,
            schedule: schedule,
            items: items
        )
        refresh()
        return loadout
    }

    var filtered: [Loadout] {
        if searchText.isEmpty { return loadouts }
        let q = searchText.lowercased()
        return loadouts.filter { loadout in
            loadout.name.lowercased().contains(q)
            || service.items(in: loadout).contains { $0.name.lowercased().contains(q) }
        }
    }

    var todaysID: UUID? {
        service.todaysLoadout()?.id
    }
}
