import SwiftUI

struct CheckHistoryView: View {
    @Environment(\.apiClient) private var api
    @Environment(\.loadoutService) private var loadoutService

    @State private var rows: [HistoryRow] = []
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DPSpacing.lg) {
                SectionHeader(title: "Check sessions", eyebrow: "\(rows.count) records")
                VStack(spacing: DPSpacing.sm) {
                    if rows.isEmpty {
                        infoRow(title: "No sessions yet", value: "Complete a Walk-Out check")
                    } else {
                        ForEach(rows) { row in
                            DPCard {
                                HStack(spacing: DPSpacing.md) {
                                    IconTile(symbol: row.loadout.symbol, tint: row.loadout.tint, size: .sm)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(row.loadout.name)
                                            .font(.system(size: 15, weight: .semibold))
                                        Text(row.subtitle)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.dpInk3)
                                    }
                                    Spacer()
                                    Image(systemName: row.session.completedAt == nil ? "clock" : "checkmark.circle.fill")
                                        .foregroundStyle(row.session.completedAt == nil ? Color.dpInk3 : Color.dpGreen)
                                }
                            }
                        }
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.dpRed)
                }
            }
            .padding(.horizontal, DPSpacing.lg)
            .padding(.bottom, DPSpacing.xxl)
        }
        .background(Color.dpBg)
        .navigationTitle("History")
        .toolbarBackground(Color.dpBg, for: .navigationBar)
        .task { await refresh() }
    }

    private func refresh() async {
        do {
            let loadouts = try await loadoutService.allLoadouts()
            var next: [HistoryRow] = []
            for loadout in loadouts {
                let sessions: [HistorySession] = try await api.get(
                    "/check-sessions",
                    query: [URLQueryItem(name: "loadoutID", value: loadout.id.uuidString)]
                )
                next.append(contentsOf: sessions.map { HistoryRow(loadout: loadout, session: $0) })
            }
            rows = next.sorted { $0.session.startedAt > $1.session.startedAt }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.system(size: 15))
            Spacer()
            Text(value).font(.system(size: 15)).foregroundStyle(Color.dpInk3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                .fill(Color.dpSurface)
        )
    }
}

private struct HistoryRow: Identifiable {
    let id = UUID()
    let loadout: Loadout
    let session: HistorySession

    var subtitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let started = formatter.string(from: session.startedAt)
        guard let completedAt = session.completedAt else {
            return "Started \(started)"
        }
        return "Completed \(formatter.string(from: completedAt))"
    }
}

private struct HistorySession: Decodable {
    let id: UUID
    let loadoutID: UUID
    let startedAt: Date
    let completedAt: Date?
}
