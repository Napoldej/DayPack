import SwiftUI

@Observable
final class TodayViewModel {
    var loadout: Loadout?
    var availableLoadouts: [Loadout] = []
    var selectedLoadoutIDs: [UUID] = []
    var selectedLoadouts: [Loadout] = []
    var items: [Item] = []
    var entries: [ChecklistEntry] = []
    var itemSources: [UUID: [Loadout]] = [:]
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
            availableLoadouts = try await service.allLoadouts()

            let storedIDs = TodayStackStorage.loadIDs()
            let validStoredIDs = storedIDs.filter { id in
                availableLoadouts.contains(where: { $0.id == id })
            }

            if validStoredIDs.isEmpty, let loadout {
                selectedLoadoutIDs = [loadout.id]
                TodayStackStorage.saveIDs(selectedLoadoutIDs)
            } else {
                selectedLoadoutIDs = validStoredIDs
            }

            selectedLoadouts = selectedLoadoutIDs.compactMap { id in
                availableLoadouts.first(where: { $0.id == id })
            }

            var mergedItems: [Item] = []
            var mergedEntries: [ChecklistEntry] = []
            var sources: [UUID: [Loadout]] = [:]
            var itemIDsByMergeKey: [String: UUID] = [:]

            for selected in selectedLoadouts {
                let loadoutItems = try await service.items(in: selected)
                let loadoutEntries = try await service.entries(for: selected)
                for item in loadoutItems {
                    let mergeKey = Self.mergeKey(for: item)
                    let representativeID = itemIDsByMergeKey[mergeKey] ?? item.id
                    itemIDsByMergeKey[mergeKey] = representativeID
                    sources[representativeID, default: []].append(selected)

                    if representativeID == item.id {
                        mergedItems.append(item)
                    }

                    if let entry = loadoutEntries.first(where: { $0.itemID == item.id }),
                       let existingIndex = mergedEntries.firstIndex(where: { $0.itemID == representativeID }) {
                        if !mergedEntries[existingIndex].isPacked && entry.isPacked {
                            mergedEntries[existingIndex] = ChecklistEntry(
                                id: entry.id,
                                itemID: representativeID,
                                isPacked: entry.isPacked
                            )
                        }
                    } else if let entry = loadoutEntries.first(where: { $0.itemID == item.id }) {
                        mergedEntries.append(
                            ChecklistEntry(
                                id: entry.id,
                                itemID: representativeID,
                                isPacked: entry.isPacked
                            )
                        )
                    }
                }
            }

            items = mergedItems
            entries = mergedEntries
            itemSources = sources

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

    func sources(for item: Item) -> [Loadout] {
        itemSources[item.id] ?? []
    }

    func isSelected(_ loadout: Loadout) -> Bool {
        selectedLoadoutIDs.contains(loadout.id)
    }

    func addToToday(_ loadout: Loadout) async {
        guard !selectedLoadoutIDs.contains(loadout.id) else { return }
        selectedLoadoutIDs.append(loadout.id)
        TodayStackStorage.saveIDs(selectedLoadoutIDs)
        await refresh()
    }

    func removeFromToday(_ loadout: Loadout) async {
        guard selectedLoadoutIDs.count > 1 else { return }
        selectedLoadoutIDs.removeAll { $0 == loadout.id }
        TodayStackStorage.saveIDs(selectedLoadoutIDs)
        await refresh()
    }

    func setBaseLoadout(_ loadout: Loadout) async {
        do {
            try await service.setTodaysLoadout(id: loadout.id)
            selectedLoadoutIDs = [loadout.id]
            TodayStackStorage.saveIDs(selectedLoadoutIDs)
            await refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func activateTomorrowLoadout(_ loadout: Loadout) async throws {
        try await service.setTodaysLoadout(id: loadout.id)
        selectedLoadoutIDs = [loadout.id]
        TodayStackStorage.saveIDs(selectedLoadoutIDs)
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

    var requiredUnpackedItems: [Item] {
        items.filter { item in
            (item.priority == .high || item.tag == "Always")
                && entry(for: item)?.isPacked != true
        }
    }

    var addableLoadouts: [Loadout] {
        availableLoadouts.filter { !selectedLoadoutIDs.contains($0.id) }
    }

    var stackTitle: String {
        guard !selectedLoadouts.isEmpty else { return loadout?.name ?? "No active loadout" }
        return selectedLoadouts.map(\.name).joined(separator: " + ")
    }

    private static func mergeKey(for item: Item) -> String {
        item.name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

enum TodayStackStorage {
    static func loadIDs() -> [UUID] {
        guard let strings = UserDefaults.standard.array(forKey: storageKey) as? [String] else { return [] }
        return strings.compactMap(UUID.init(uuidString:))
    }

    static func saveIDs(_ ids: [UUID]) {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: storageKey)
    }

    private static var storageKey: String {
        "todayStack.selectedLoadoutIDs.\(dayKey())"
    }

    private static func dayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
