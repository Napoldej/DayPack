import SwiftUI

struct TodayView: View {
    @Environment(\.loadoutService) private var service
    @Environment(\.homeLocationService) private var homeLocationService
    @State private var viewModel: TodayViewModel?
    @State private var showWalkOut = false

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
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
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .fullScreenCover(isPresented: $showWalkOut) {
                NavigationStack {
                    WalkOutChecklistView()
                }
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
            // MARK: – Header
            headerSection(vm: vm)

            if !vm.selectedLoadouts.isEmpty {
                dayStackSection(vm: vm)

                if homeLocationService.presence == .away && !vm.requiredUnpackedItems.isEmpty {
                    leavingHomeWarning(vm: vm)
                }

                if let loadout = vm.loadout,
                   loadout.isSuggestedForTomorrow || loadout.isTemporary || loadout.alertTime != nil || loadout.returnAlertTime != nil {
                    smartTimingPanel(loadout)
                }

                // MARK: – Checklist
                checklistSection(vm: vm)

                PrimaryButton(title: "Start Walk-Out Check", icon: "arrow.right") {
                    showWalkOut = true
                }
                .padding(.horizontal, DPSpacing.base)

                if vm.shouldShowTomorrowPreview {
                    tomorrowPreviewSection(vm: vm)
                }
            } else {
                EmptyStateView(
                    symbol: "backpack",
                    title: "No loadout for today",
                    message: "Create a loadout to start packing."
                )
                .padding(.horizontal, DPSpacing.base)

                if vm.shouldShowTomorrowPreview {
                    tomorrowPreviewSection(vm: vm)
                }
            }
        }
        .padding(.bottom, 116)
    }

    // MARK: – Header

    private func headerSection(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(dateString)
                        .dpEyebrow()
                    Text("Morning,\nDayPack.")
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .italic()
                        .lineSpacing(-4)
                        .foregroundStyle(Color.dpInk)
                }
                Spacer()
                locationPill
            }

            if vm.totalCount > 0 {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    HStack(spacing: 8) {
                        Circle().fill(Color.dpOrange).frame(width: 6, height: 6)
                        Text("Today's stack · \(vm.stackTitle)")
                            .font(.system(size: 11, weight: .bold))
                            .textCase(.uppercase)
                            .foregroundStyle(Color.dpInk4)
                    }

                    Text(activeTitle(vm))
                        .font(.system(size: 38, weight: .bold, design: .serif))
                        .italic()
                        .foregroundStyle(Color.dpBg)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(vm.packedCount)")
                            .font(.system(size: 72, weight: .black))
                            .foregroundStyle(Color.dpOrange)
                        Text("/ \(vm.totalCount)")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .italic()
                            .foregroundStyle(Color.dpInk4)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("packed")
                            Text("\(max(vm.totalCount - vm.packedCount, 0)) to go")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.dpInk4)
                    }

                    ProgressBar(
                        value: vm.progress,
                        size: .lg,
                        fillColor: .dpOrange,
                        trackColor: Color.dpBg.opacity(0.12)
                    )

                    Button {
                        showWalkOut = true
                    } label: {
                        HStack {
                            Text("Start check")
                                .font(.system(size: 14, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundStyle(Color.dpInk)
                        .frame(height: 42)
                        .padding(.horizontal, 18)
                        .background(Capsule().fill(Color.dpOrange))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.dpInk)
                )
                .shadow(color: Color.dpInk.opacity(0.18), radius: 22, x: 0, y: 12)
            }
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.top, DPSpacing.sm)
    }

    private var locationPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(locationStatusColor)
                .frame(width: 22, height: 22)
                .overlay(
                    Image(systemName: "house.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.dpInk)
                )
            Text(locationStatusText)
                .font(.system(size: 10, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(Color.dpInk2)
        }
        .padding(.leading, 8)
        .padding(.trailing, 12)
        .frame(height: 36)
        .background(Capsule().fill(Color.dpSurface))
        .overlay(Capsule().stroke(Color.dpDivider, lineWidth: 1))
    }

    private func activeTitle(_ vm: TodayViewModel) -> String {
        guard let first = vm.selectedLoadouts.first else { return "Today's pack" }
        if vm.selectedLoadouts.count > 1 {
            return "\(first.name) day"
        }
        return first.name
    }

    // MARK: – Day stack

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
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.dpInk)
                                Text(loadout.schedule)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.dpInk3)
                            }
                            Spacer()
                            if vm.selectedLoadouts.count > 1 {
                                Button {
                                    Task { await vm.removeFromToday(loadout) }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color.dpInk4)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Remove \(loadout.name) from today")
                            }
                        }
                    }

                    if !vm.addableLoadouts.isEmpty {
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DPSpacing.sm) {
                                ForEach(vm.addableLoadouts) { loadout in
                                    Button {
                                        Task { await vm.addToToday(loadout) }
                                    } label: {
                                        Label(loadout.name, systemImage: "plus")
                                            .font(.system(size: 13, weight: .semibold))
                                            .lineLimit(1)
                                            .foregroundStyle(Color.dpInk)
                                            .padding(.horizontal, 12)
                                            .frame(height: 32)
                                            .background(
                                                Capsule().fill(Color.dpSurfaceAlt)
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
        .padding(.horizontal, DPSpacing.base)
    }

    private func leavingHomeWarning(vm: TodayViewModel) -> some View {
        DPCard(background: Color.dpOrangeSoft) {
            HStack(alignment: .top, spacing: DPSpacing.md) {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.dpOrange)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.white))

                VStack(alignment: .leading, spacing: DPSpacing.xs) {
                    Text("Check before you leave")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.dpInk)
                    Text("\(vm.requiredUnpackedItems.count) required item\(vm.requiredUnpackedItems.count == 1 ? "" : "s") still unpacked.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.dpInk2)
                    HStack(spacing: 6) {
                        ForEach(vm.requiredUnpackedItems.prefix(3)) { item in
                            Pill(text: item.name, style: .warn)
                        }
                    }
                }
                Spacer(minLength: DPSpacing.sm)
            }
        }
        .padding(.horizontal, DPSpacing.base)
    }

    private var locationStatusText: String {
        guard homeLocationService.hasHomeLocation else { return "Home not set" }
        switch homeLocationService.presence {
        case .atHome:       return "At home"
        case .away:         return "Away"
        case .unavailable:  return "Location unavailable"
        case .unknown:      return "Checking…"
        }
    }

    private var locationStatusColor: Color {
        switch homeLocationService.presence {
        case .atHome:      return Color.dpGreen
        case .away:        return Color.dpOrange
        case .unavailable: return Color.dpRed
        case .unknown:     return Color.dpInk4
        }
    }

    // MARK: – Checklist

    private func checklistSection(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Pack list", eyebrow: "\(vm.packedCount) of \(vm.totalCount)")
                .padding(.horizontal, DPSpacing.base)

            VStack(spacing: 0) {
                ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                    MergedChecklistItemRow(
                        item: item,
                        isPacked: vm.entry(for: item)?.isPacked ?? false,
                        sources: vm.sources(for: item),
                        onToggle: { Task { await vm.togglePacked(for: item) } }
                    )
                    if index < vm.items.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .background(Color.dpSurface)
            .clipShape(RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .stroke(Color.dpDivider, lineWidth: 1)
            )
            .dpShadow(.soft)
            .padding(.horizontal, DPSpacing.base)
        }
    }

    // MARK: – Tomorrow

    @ViewBuilder
    private func tomorrowPreviewSection(vm: TodayViewModel) -> some View {
        VStack(alignment: .leading, spacing: DPSpacing.md) {
            SectionHeader(title: "Tomorrow", eyebrow: "Get ready")

            if !vm.tomorrow.temporary.isEmpty {
                tomorrowGroup(label: "Temporary", loadouts: vm.tomorrow.temporary, vm: vm)
            }
            if !vm.tomorrow.scheduled.isEmpty {
                tomorrowGroup(label: "Scheduled", loadouts: vm.tomorrow.scheduled, vm: vm)
            }
        }
        .padding(.horizontal, DPSpacing.base)
        .padding(.top, DPSpacing.sm)
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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.dpInk)
                    Spacer()
                }

                VStack(spacing: DPSpacing.sm) {
                    if let alertTime = loadout.alertTime {
                        timingRow(symbol: "bell.fill", title: "Departure", value: alertTime)
                    } else {
                        timingRow(symbol: "location.fill", title: "Departure", value: "Geofence")
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
        .padding(.horizontal, DPSpacing.base)
    }

    private func smartTimingTitle(_ loadout: Loadout) -> String {
        if loadout.isTemporary { return "Temporary pack" }
        if loadout.isSuggestedForTomorrow { return "Tomorrow's pack" }
        return "Smart timing"
    }

    private func timingRow(symbol: String, title: String, value: String) -> some View {
        HStack(spacing: DPSpacing.sm) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.dpInk3)
                .frame(width: 18)
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.dpInk2)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
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

// MARK: – Merged checklist row

private struct MergedChecklistItemRow: View {
    let item: Item
    var isPacked: Bool
    var sources: [Loadout]
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DPSpacing.md) {
                CheckboxIcon(checked: isPacked)
                IconTile(symbol: item.symbol, tint: item.tint, size: .sm)
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isPacked ? Color.dpInk3 : Color.dpInk)
                        .strikethrough(isPacked, color: Color.dpInk4)

                    if !sources.isEmpty {
                        Text(sources.map(\.name).joined(separator: ", "))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.dpInk3)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 4)
                if let tag = item.tag {
                    Pill(text: tag, style: tagStyle(tag, priority: item.priority))
                }
            }
            .padding(.horizontal, DPSpacing.base)
            .padding(.vertical, DPSpacing.md)
            .frame(minHeight: 56)
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

private struct CheckboxIcon: View {
    let checked: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dpInk4, lineWidth: 1.5)
                .frame(width: 24, height: 24)
                .opacity(checked ? 0 : 1)
            Circle()
                .fill(Color.dpInk)
                .frame(width: 24, height: 24)
                .opacity(checked ? 1 : 0)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.dpOrange)
            }
        }
        .animation(.easeOut(duration: 0.15), value: checked)
    }
}

#Preview {
    TodayView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
