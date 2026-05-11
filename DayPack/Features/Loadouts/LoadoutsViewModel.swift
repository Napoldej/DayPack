import SwiftUI

@Observable
final class LoadoutsViewModel {
    var loadouts: [Loadout] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let service: any LoadoutService
    private var itemCounts: [UUID: Int] = [:]
    private var itemNames: [UUID: [String]] = [:]
    private var todaysLoadoutID: UUID?

    init(service: any LoadoutService) {
        self.service = service
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            loadouts = try await service.allLoadouts()
            todaysLoadoutID = try await service.todaysLoadout()?.id
            itemCounts = [:]
            itemNames = [:]
            for loadout in loadouts {
                let items = try await service.items(in: loadout)
                itemCounts[loadout.id] = items.count
                itemNames[loadout.id] = items.map { $0.name.lowercased() }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func itemCount(for loadout: Loadout) -> Int {
        itemCounts[loadout.id] ?? loadout.itemIDs.count
    }

    func setToday(_ loadout: Loadout) async {
        do {
            try await service.setTodaysLoadout(id: loadout.id)
            todaysLoadoutID = loadout.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteLoadout(_ loadout: Loadout) async {
        do {
            try await service.deleteLoadout(id: loadout.id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func createLoadout(
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        items: [Item],
        isTemporary: Bool,
        alertTime: String?,
        returnAlertTime: String?
    ) async -> Loadout? {
        do {
            let loadout = try await service.createLoadout(
                name: name,
                symbol: symbol,
                tint: tint,
                schedule: schedule,
                items: items,
                isTemporary: isTemporary,
                alertTime: alertTime,
                returnAlertTime: returnAlertTime
            )
            await refresh()
            return loadout
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    var filtered: [Loadout] {
        if searchText.isEmpty { return loadouts }
        let q = searchText.lowercased()
        return loadouts.filter { loadout in
            loadout.name.lowercased().contains(q)
            || (itemNames[loadout.id]?.contains { $0.contains(q) } ?? false)
        }
    }

    var todaysID: UUID? {
        todaysLoadoutID
    }
}
