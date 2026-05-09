import SwiftUI

struct TodayView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: TodayViewModel?
    @State private var showWalkOut = false

    private var subtitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · MMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vm = viewModel {
                    content(vm: vm)
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Today")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showWalkOut) {
                WalkOutChecklistView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = TodayViewModel(service: service)
                Task { await viewModel?.refresh() }
            } else {
                Task { await viewModel?.refresh() }
            }
        }
    }

    @ViewBuilder
    private func content(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.lg) {
            HStack(spacing: 8) {
                Circle().fill(Color.dpGreen).frame(width: 8, height: 8)
                Text("At Home · ready to leave anytime")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.dpInk2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.dpGreenSoft))

            Text(subtitle)
                .dpSubhead()
                .foregroundStyle(Color.dpInk3)

            if let loadout = vm.loadout {
                LoadoutCard(loadout: loadout, itemCount: vm.totalCount, isActive: true)

                if loadout.isSuggestedForTomorrow || loadout.isTemporary || loadout.alertTime != nil || loadout.returnAlertTime != nil {
                    smartTimingPanel(loadout)
                }

                DPCard {
                    VStack(alignment: .leading, spacing: DPSpacing.md) {
                        ProgressBar(
                            value: vm.progress,
                            size: .lg,
                            label: "\(vm.packedCount) of \(vm.totalCount) packed",
                            trailingLabel: "\(Int(vm.progress * 100))%"
                        )
                        Text("Tap an item to mark it packed.")
                            .dpCaption()
                            .foregroundStyle(Color.dpInk3)
                    }
                }

                VStack(spacing: DPSpacing.sm) {
                    ForEach(vm.items) { item in
                        ChecklistItemRow(
                            item: item,
                            isPacked: vm.entry(for: item)?.isPacked ?? false,
                            onToggle: { Task { await vm.togglePacked(for: item) } }
                        )
                    }
                }

                PrimaryButton(title: "Start Walk-Out Check", icon: "arrow.right") {
                    showWalkOut = true
                }
                .padding(.top, DPSpacing.sm)

                if vm.shouldShowTomorrowPreview {
                    tomorrowPreviewSection(vm: vm)
                }
            } else {
                EmptyStateView(
                    symbol: "backpack",
                    title: "No loadout for today",
                    message: "Create a loadout to start packing from real backend data."
                )

                if vm.shouldShowTomorrowPreview {
                    tomorrowPreviewSection(vm: vm)
                }
            }
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.bottom, DPSpacing.xxl)
    }

    @ViewBuilder
    private func tomorrowPreviewSection(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Tomorrow's pack", eyebrow: "Get ready tonight")

            if !vm.tomorrow.temporary.isEmpty {
                tomorrowGroup(label: "Temporary", loadouts: vm.tomorrow.temporary, vm: vm)
            }
            if !vm.tomorrow.scheduled.isEmpty {
                tomorrowGroup(label: "Scheduled", loadouts: vm.tomorrow.scheduled, vm: vm)
            }
        }
        .padding(.top, DPSpacing.lg)
    }

    @ViewBuilder
    private func tomorrowGroup(label: String, loadouts: [Loadout], vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.sm) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(Color.dpInk3)

            ForEach(loadouts) { loadout in
                LoadoutCard(
                    loadout: loadout,
                    itemCount: vm.itemCount(for: loadout),
                    isActive: false,
                    style: .compact,
                    onTap: {
                        Task {
                            try? await vm.activateTomorrowLoadout(loadout)
                        }
                    }
                )
            }
        }
    }

    private func smartTimingPanel(_ loadout: Loadout) -> some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                HStack(spacing: 8) {
                    Image(systemName: loadout.isTemporary ? "sparkles" : "calendar")
                        .foregroundStyle(Color.dpOrange)
                    Text(smartTimingTitle(loadout))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.dpInk)
                    Spacer()
                }

                VStack(spacing: DPSpacing.sm) {
                    if let alertTime = loadout.alertTime {
                        timingRow(symbol: "bell.fill", title: "Departure", value: alertTime)
                    } else {
                        timingRow(symbol: "location.fill", title: "Departure", value: "Geofence fallback")
                    }

                    if let returnAlertTime = loadout.returnAlertTime {
                        timingRow(symbol: "arrow.uturn.backward.circle.fill", title: "Return", value: returnAlertTime)
                    }

                    if loadout.isTemporary, let expiresAt = loadout.expiresAt {
                        timingRow(symbol: "calendar.badge.clock", title: "Expires", value: expiryText(expiresAt))
                    }

                    if loadout.isSuggestedForTomorrow {
                        timingRow(symbol: "sparkles", title: "Suggestion", value: "Scheduled for tomorrow")
                    }
                }
            }
        }
    }

    private func smartTimingTitle(_ loadout: Loadout) -> String {
        if loadout.isTemporary { return "Temporary pack for tomorrow" }
        if loadout.isSuggestedForTomorrow { return "Tomorrow's suggested pack" }
        return "Smart timing"
    }

    private func timingRow(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: DPSpacing.sm) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.dpInk3)
                .frame(width: 18)
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.dpInk2)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.dpInk3)
        }
    }

    private func expiryText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    TodayView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
