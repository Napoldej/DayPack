import Foundation
import SwiftUI

protocol LoadoutService: AnyObject {
    func todaysLoadout() -> Loadout?
    func allLoadouts() -> [Loadout]
    func items(in loadout: Loadout) -> [Item]
    func entries(for loadout: Loadout) -> [ChecklistEntry]
    func togglePacked(entryID: UUID)
    @discardableResult
    func createLoadout(name: String, symbol: String, tint: ItemTint, schedule: String, items: [Item]) -> Loadout
    func setTodaysLoadout(id: UUID)
    func recentDayStats(days: Int) -> [DayStat]
    func currentStreak() -> Int
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
