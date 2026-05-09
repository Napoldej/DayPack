import Foundation
import SwiftUI

struct TomorrowPreview: Hashable {
    var scheduled: [Loadout]
    var temporary: [Loadout]

    var all: [Loadout] { temporary + scheduled }
    var isEmpty: Bool { scheduled.isEmpty && temporary.isEmpty }
}

protocol LoadoutService: AnyObject {
    func todaysLoadout() async throws -> Loadout?
    func allLoadouts() async throws -> [Loadout]
    func loadoutsForTomorrow() async throws -> TomorrowPreview
    func items(in loadout: Loadout) async throws -> [Item]
    func entries(for loadout: Loadout) async throws -> [ChecklistEntry]
    func togglePacked(entryID: UUID) async throws
    func completeCheck(for loadout: Loadout) async throws
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
    ) async throws -> Loadout
    func updateLoadout(
        _ loadout: Loadout,
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        isTemporary: Bool,
        alertTime: String?,
        returnAlertTime: String?
    ) async throws -> Loadout
    func deleteLoadout(id: UUID) async throws
    func addItem(to loadout: Loadout, item: Item) async throws -> Item
    func updateItem(_ item: Item) async throws -> Item
    func deleteItem(id: UUID, from loadout: Loadout) async throws
    func setTodaysLoadout(id: UUID) async throws
    func recentDayStats(days: Int) async throws -> [DayStat]
    func currentStreak() async throws -> Int
}

private struct LoadoutServiceKey: EnvironmentKey {
    static let defaultValue: any LoadoutService = MockLoadoutService.shared
}

extension EnvironmentValues {
    var loadoutService: any LoadoutService {
        get { self[LoadoutServiceKey.self] }
        set { self[LoadoutServiceKey.self] = newValue }
    }
}
