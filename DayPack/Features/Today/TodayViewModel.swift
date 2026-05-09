import SwiftUI

@Observable
final class TodayViewModel {
    var loadout: Loadout?
    var items: [Item] = []
    var entries: [ChecklistEntry] = []
    var tomorrow: TomorrowPreview = TomorrowPreview(scheduled: [], temporary: [])
    var tomorrowItemCounts: [UUID: Int] = [:]
    var isLoading: Bool = false
    var errorMessage: String?

    private let service: any LoadoutService

    init(service: any LoadoutService) {
        self.service = service
    }

    func refresh() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            loadout = try await service.todaysLoadout()
            if let loadout {
                items = try await service.items(in: loadout)
                entries = try await service.entries(for: loadout)
            } else {
                items = []
                entries = []
            }

            tomorrow = try await service.loadoutsForTomorrow()
            tomorrowItemCounts = [:]
            for previewLoadout in tomorrow.all {
                let count = (try? await service.items(in: previewLoadout).count) ?? previewLoadout.itemIDs.count
                tomorrowItemCounts[previewLoadout.id] = count
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func itemCount(for previewLoadout: Loadout) -> Int {
        tomorrowItemCounts[previewLoadout.id] ?? previewLoadout.itemIDs.count
    }

    var shouldShowTomorrowPreview: Bool {
        guard !tomorrow.isEmpty else { return false }
        if let active = loadout, active.isSuggestedForTomorrow,
           tomorrow.all.count == 1, tomorrow.all.first?.id == active.id {
            return false
        }
        return true
    }

    func entry(for item: Item) -> ChecklistEntry? {
        entries.first(where: { $0.itemID == item.id })
    }

    func activateTomorrowLoadout(_ loadout: Loadout) async throws {
        try await service.setTodaysLoadout(id: loadout.id)
        await refresh()
    }

    func togglePacked(for item: Item) async {
        guard let entry = entry(for: item) else { return }
        do {
            try await service.togglePacked(entryID: entry.id)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func completeCheck() async {
        guard let loadout else { return }
        do {
            try await service.completeCheck(for: loadout)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
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
