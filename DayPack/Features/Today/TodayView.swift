import SwiftUI

struct TodayView: View {
    @Environment(\.loadoutService) private var service
    @Environment(\.homeLocationService) private var homeLocationService
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
            homeLocationService.refreshLocationState()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dayPackOpenWalkOut)) { _ in
            showWalkOut = true
        }
    }

    @ViewBuilder
    private func content(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.lg) {
            todayHeader(vm: vm)

            if !vm.selectedLoadouts.isEmpty {
                dayStackSection(vm: vm)

                if homeLocationService.presence == .away && !vm.requiredUnpackedItems.isEmpty {
                    leavingHomeWarning(vm: vm)
                }

                if let loadout = vm.loadout,
                   loadout.isSuggestedForTomorrow || loadout.isTemporary || loadout.alertTime != nil || loadout.returnAlertTime != nil {
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
                        MergedChecklistItemRow(
                            item: item,
                            isPacked: vm.entry(for: item)?.isPacked ?? false,
                            sources: vm.sources(for: item),
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

    private func todayHeader(vm: TodayViewModel) -> some View {
        DPCard(padding: DPSpacing.lg, shadow: .soft) {
            HStack(alignment: .top, spacing: DPSpacing.md) {
                VStack(alignment: .leading, spacing: DPSpacing.sm) {
                    HStack(spacing: 8) {
                        Circle().fill(locationStatusColor).frame(width: 8, height: 8)
                        Text(locationStatusText)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(locationStatusColor)
                    }

                    Text(subtitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)

                    Text(vm.stackTitle)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.dpInk)
                        .lineLimit(2)
                }

                Spacer(minLength: DPSpacing.md)

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(vm.packedCount)")
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(Color.dpOrange)
                    Text("of \(vm.totalCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.dpInk3)
                }
                .accessibilityLabel("\(vm.packedCount) of \(vm.totalCount) packed")
            }
        }
    }

    private func dayStackSection(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Today's plan", eyebrow: "\(vm.selectedLoadouts.count) pack\(vm.selectedLoadouts.count == 1 ? "" : "s") merged")

            DPCard {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    ForEach(vm.selectedLoadouts) { loadout in
                        HStack(spacing: DPSpacing.md) {
                            IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .sm)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(loadout.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.dpInk)
                                Text(loadout.schedule)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.dpInk3)
                            }
                            Spacer()
                            if vm.selectedLoadouts.count > 1 {
                                Button {
                                    Task { await vm.removeFromToday(loadout) }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color.dpInk4)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(loadout.name) from today")
                            }
                        }
                    }

                    if !vm.addableLoadouts.isEmpty {
                        Divider().background(Color.dpHairline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DPSpacing.sm) {
                                ForEach(vm.addableLoadouts) { loadout in
                                    Button {
                                        Task { await vm.addToToday(loadout) }
                                    } label: {
                                        Label(loadout.name, systemImage: "plus")
                                            .font(.system(size: 13, weight: .bold))
                                            .lineLimit(1)
                                            .foregroundStyle(Color.dpInk)
                                            .padding(.horizontal, 12)
                                            .frame(height: 34)
                                            .background(
                                                Capsule()
                                                    .fill(Color.dpSurfaceAlt)
                                                    .overlay(Capsule().stroke(Color.dpDivider, lineWidth: 1))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func leavingHomeWarning(vm: TodayViewModel) -> some View {
        DPCard {
            HStack(alignment: .top, spacing: DPSpacing.md) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.dpOrange)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.dpOrangeSoft))

                VStack(alignment: .leading, spacing: DPSpacing.xs) {
                    Text("Check before you leave")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.dpInk)
                    Text("\(vm.requiredUnpackedItems.count) required item\(vm.requiredUnpackedItems.count == 1 ? "" : "s") still unpacked.")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                    HStack(spacing: 6) {
                        ForEach(vm.requiredUnpackedItems.prefix(3)) { item in
                            Pill(text: item.name, style: .warn)
                        }
                    }
                }
                Spacer(minLength: DPSpacing.sm)
            }
        }
    }

    private var locationStatusText: String {
        guard homeLocationService.hasHomeLocation else { return "Home not set" }
        switch homeLocationService.presence {
        case .atHome:
            return "At home"
        case .away:
            return "Away from home"
        case .unavailable:
            return "Location unavailable"
        case .unknown:
            return "Checking location"
        }
    }

    private var locationStatusColor: Color {
        switch homeLocationService.presence {
        case .atHome:
            return Color.dpGreen
        case .away:
            return Color.dpOrange
        case .unavailable:
            return Color.dpRed
        case .unknown:
            return Color.dpInk3
        }
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

private struct MergedChecklistItemRow: View {
    let item: Item
    var isPacked: Bool
    var sources: [Loadout]
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DPSpacing.md) {
                CheckboxGlyph(checked: isPacked)
                IconTile(symbol: item.symbol, tint: item.tint, size: .sm)
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isPacked ? Color.dpInk3 : Color.dpInk)
                        .strikethrough(isPacked, color: Color.dpInk4)

                    if !sources.isEmpty {
                        Text("Needed for \(sources.map(\.name).joined(separator: ", "))")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.dpInk3)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 4)
                if let tag = item.tag {
                    Pill(text: tag, style: tagStyle(tag, priority: item.priority))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 62)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                    .fill(item.priority == .high && !isPacked ? Color.dpOrangeMuted : Color.dpSurface)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(Text(item.name))
        .accessibilityValue(Text(isPacked ? "packed" : "not packed"))
        .accessibilityAddTraits(isPacked ? .isSelected : [])
    }

    private func tagStyle(_ tag: String, priority: Priority) -> Pill.Style {
        if priority == .high { return .warn }
        switch tag {
        case "Don't forget": return .warn
        case "Always":       return .neutral
        default:             return .neutral
        }
    }
}

private struct CheckboxGlyph: View {
    let checked: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dpInk4, lineWidth: 1.6)
                .frame(width: 26, height: 26)
                .opacity(checked ? 0 : 1)
            Circle()
                .fill(Color.dpGreen)
                .frame(width: 26, height: 26)
                .opacity(checked ? 1 : 0)
                .shadow(color: Color.dpGreen.opacity(0.33), radius: 3, x: 0, y: 2)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .animation(.spring(duration: 0.22), value: checked)
    }
}

#Preview {
    TodayView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
