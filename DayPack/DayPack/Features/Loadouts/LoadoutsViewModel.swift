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

    var filtered: [Loadout] {
        if searchText.isEmpty { return loadouts }
        let q = searchText.lowercased()
        return loadouts.filter { $0.name.lowercased().contains(q) }
    }

    var todaysID: UUID? {
        service.todaysLoadout()?.id
    }
}
