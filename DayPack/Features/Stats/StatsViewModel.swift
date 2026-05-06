import SwiftUI

@Observable
final class StatsViewModel {
    var streak: Int = 0
    var heatmap: [DayStat] = []
    var perLoadout: [LoadoutCompletion] = []

    struct LoadoutCompletion: Identifiable, Hashable {
        let id: UUID
        let loadout: Loadout
        let completion: Double
    }

    private let service: any LoadoutService

    init(service: any LoadoutService) {
        self.service = service
        refresh()
    }

    func refresh() {
        streak = service.currentStreak()
        heatmap = service.recentDayStats(days: 30)
        perLoadout = service.allLoadouts().map { loadout in
            let entries = service.entries(for: loadout)
            let packed = entries.filter { $0.isPacked }.count
            let total = max(entries.count, 1)
            return LoadoutCompletion(
                id: loadout.id,
                loadout: loadout,
                completion: Double(packed) / Double(total)
            )
        }
    }

    var weekDots: [Bool] {
        let last7 = Array(heatmap.suffix(7))
        return last7.map { $0.completion >= 0.999 }
    }
}
