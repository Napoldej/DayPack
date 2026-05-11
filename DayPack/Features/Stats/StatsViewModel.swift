import SwiftUI

@Observable
final class StatsViewModel {
    var streak: Int = 0
    var heatmap: [DayStat] = []
    var perLoadout: [LoadoutCompletion] = []
    var errorMessage: String?

    struct LoadoutCompletion: Identifiable, Hashable {
        let id: UUID
        let loadout: Loadout
        let completion: Double
    }

    private let service: any LoadoutService

    init(service: any LoadoutService) {
        self.service = service
    }

    func refresh() async {
        do {
            streak = try await service.currentStreak()
            heatmap = try await service.recentDayStats(days: 30)
            let loadouts = try await service.allLoadouts()
            var completions: [LoadoutCompletion] = []
            for loadout in loadouts {
                let entries = try await service.entries(for: loadout)
                let packed = entries.filter { $0.isPacked }.count
                let total = max(entries.count, 1)
                completions.append(
                    LoadoutCompletion(
                        id: loadout.id,
                        loadout: loadout,
                        completion: Double(packed) / Double(total)
                    )
                )
            }
            perLoadout = completions
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var weekDots: [Bool] {
        let last7 = Array(heatmap.suffix(7))
        return last7.map { $0.completion >= 0.999 }
    }
}
