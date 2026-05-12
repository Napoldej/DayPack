import SwiftUI

struct WalkOutChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.loadoutService) private var service
    @State private var viewModel: TodayViewModel?
    @State private var hasLoaded = false
    @State private var showSuccess = false
    @State private var completedCount = 0

    private var allRequiredPacked: Bool {
        guard let vm = viewModel else { return false }
        guard vm.totalCount > 0 else { return false }
        let required = vm.items.filter { $0.priority == .high || $0.tag == "Always" }
        return required.allSatisfy { item in
            vm.entry(for: item)?.isPacked == true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if let vm = viewModel {
                checklistContent(vm: vm)
            } else {
                loadingState
            }
        }
        .background(Color.dpInk)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if let vm = viewModel, vm.totalCount > 0 {
                bottomActionBar(vm: vm)
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if viewModel == nil {
                viewModel = TodayViewModel(service: service)
                Task { await refresh() }
            } else {
                Task { await refresh() }
            }
        }
        .fullScreenCover(isPresented: $showSuccess) {
            PerfectDepartureView(packedCount: completedCount) {
                showSuccess = false
                dismiss()
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.dpBg)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color.dpBg.opacity(0.06))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.dpBg.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(PressableButtonStyle())

            Spacer()

            Text("Walk-out check")
                .font(.system(size: 12, weight: .black))
                .textCase(.uppercase)
                .foregroundStyle(Color.dpInk4)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.top, DPSpacing.md)
        .padding(.bottom, DPSpacing.sm)
        .background(Color.dpInk)
    }

    @ViewBuilder
    private func checklistContent(vm: TodayViewModel) -> some View {
        if vm.isLoading && !hasLoaded {
            loadingState
        } else if let errorMessage = vm.errorMessage {
            errorState(message: errorMessage)
        } else if vm.totalCount == 0 {
            emptyChecklistState
        } else {
            ScrollView {
                VStack(spacing: DPSpacing.lg) {
                    statusHeader(vm: vm)
                        .padding(.top, DPSpacing.base)

                    section(title: "Essentials", eyebrow: "Always", items: vm.items.filter { $0.tag == "Always" }, vm: vm)
                    section(title: loadoutSectionTitle(vm), eyebrow: "Today", items: vm.items.filter { $0.tag != "Always" && $0.tag != "Optional" }, vm: vm)
                    section(title: "Optional", eyebrow: "Nice-to-have", items: vm.items.filter { $0.tag == "Optional" }, vm: vm)
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, 110)
            }
            .background(Color.dpInk)
        }
    }

    private var loadingState: some View {
        VStack(spacing: DPSpacing.md) {
            ProgressView()
                .tint(Color.dpOrange)
            Text("Getting your check ready")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.dpBg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpInk)
    }

    private var emptyChecklistState: some View {
        ScrollView {
            EmptyStateView(
                symbol: "checklist",
                title: "Nothing to check yet",
                message: "Choose a loadout from the Loadouts tab so your home screen can become your walk-out checklist."
            )
            .padding(.horizontal, DPSpacing.lg)
        }
        .background(Color.dpBg)
    }

    private func errorState(message: String) -> some View {
        ScrollView {
            EmptyStateView(
                symbol: "wifi.exclamationmark",
                title: "Could not load check",
                message: message,
                ctaTitle: "Try Again",
                ctaAction: {
                    Task { await refresh() }
                }
            )
            .padding(.horizontal, DPSpacing.lg)
        }
        .background(Color.dpBg)
    }

    private func refresh() async {
        await viewModel?.refresh()
        hasLoaded = true
    }

    private func statusHeader(vm: TodayViewModel) -> some View {
        HStack(alignment: .center, spacing: DPSpacing.lg) {
            progressDial(vm: vm)

            VStack(alignment: .leading, spacing: DPSpacing.sm) {
                Text(allRequiredPacked ? "Ready to go." : "Almost ready.")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .italic()
                    .lineSpacing(-4)
                    .foregroundStyle(Color.dpBg)
                    .fixedSize(horizontal: false, vertical: true)

                Text(statusMessage(vm))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.dpInk4)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DPSpacing.base)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .fill(Color.dpBg.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DPRadius.xxl, style: .continuous)
                .stroke(Color.dpBg.opacity(0.10), lineWidth: 1)
        )
    }

    private func progressDial(vm: TodayViewModel) -> some View {
        let percent = Int((vm.progress * 100).rounded())

        return ZStack {
            Circle()
                .stroke(Color.dpBg.opacity(0.10), lineWidth: 8)

            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    Color.dpOrange,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(percent)%")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(Color.dpOrange)

                Text("\(vm.packedCount)/\(vm.totalCount)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Color.dpInk4)
            }
        }
        .frame(width: 98, height: 98)
        .accessibilityLabel("Packed \(vm.packedCount) of \(vm.totalCount) items")
    }

    private func statusMessage(_ vm: TodayViewModel) -> String {
        if let missing = vm.requiredUnpackedItems.first {
            return "\(missing.name) is required and still missing. Tap it when packed."
        }

        if vm.totalCount == vm.packedCount {
            return "Everything in \(vm.stackTitle) is checked. You can head out."
        }

        return "Required items are packed. Optional items can still be checked."
    }

    private func loadoutSectionTitle(_ vm: TodayViewModel) -> String {
        guard !vm.selectedLoadouts.isEmpty else { return "Loadout" }
        return vm.selectedLoadouts.count == 1 ? "Loadout · \(vm.stackTitle)" : "Loadout · Today stack"
    }

    private func bottomActionBar(vm: TodayViewModel) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.dpBg.opacity(0.08))
                .frame(height: 1)
            Button {
                Task {
                    completedCount = vm.packedCount
                    await vm.completeCheck()
                    showSuccess = true
                }
            } label: {
                HStack(spacing: 10) {
                    Text(allRequiredPacked ? "I'm Ready to Go" : "Pack required items first")
                        .font(.system(size: 17, weight: .black))
                    if allRequiredPacked {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .black))
                    }
                }
                .foregroundStyle(Color.dpInk)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Capsule()
                        .fill(allRequiredPacked ? Color.dpOrange : Color.dpInk4.opacity(0.35))
                )
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!allRequiredPacked)
            .padding(.horizontal, DPSpacing.lg)
            .padding(.top, DPSpacing.md)
            .padding(.bottom, DPSpacing.sm)
        }
        .background(Color.dpInk)
    }

    @ViewBuilder
    private func section(title: String, eyebrow: String, items: [Item], vm: TodayViewModel) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                let packedInGroup = items.filter { vm.entry(for: $0)?.isPacked == true }.count
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(eyebrow) · \(packedInGroup)/\(items.count)")
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.dpInk4)
                    Text(title)
                        .font(.system(size: 17, weight: .black))
                        .foregroundStyle(Color.dpBg)
                }

                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        darkChecklistRow(
                            item: item,
                            isPacked: vm.entry(for: item)?.isPacked ?? false,
                            onToggle: { Task { await vm.togglePacked(for: item) } }
                        )
                        if index < items.count - 1 {
                            Divider()
                                .overlay(Color.dpBg.opacity(0.08))
                                .padding(.leading, 56)
                        }
                    }
                }
                .padding(4)
                .background(Color.dpBg.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                        .stroke(Color.dpBg.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }

    private func darkChecklistRow(item: Item, isPacked: Bool, onToggle: @escaping () -> Void) -> some View {
        Button(action: onToggle) {
            HStack(spacing: DPSpacing.md) {
                ZStack {
                    Circle()
                        .stroke(item.priority == .high ? Color.dpOrange : Color.dpBg.opacity(0.28), lineWidth: 1.5)
                        .frame(width: 28, height: 28)
                        .opacity(isPacked ? 0 : 1)
                    Circle()
                        .fill(Color.dpOrange)
                        .frame(width: 28, height: 28)
                        .opacity(isPacked ? 1 : 0)
                    if isPacked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Color.dpInk)
                    }
                }

                Image(systemName: item.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isPacked ? Color.dpInk4 : Color.dpBg)
                    .frame(width: 24)

                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isPacked ? Color.dpInk4 : Color.dpBg)
                    .strikethrough(isPacked, color: Color.dpInk4)

                Spacer(minLength: 4)

                if item.priority == .high && !isPacked {
                    Pill(text: "Required", style: .brand)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .fill(isPacked ? Color.dpOrange.opacity(0.06) : .clear)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    NavigationStack {
        WalkOutChecklistView()
            .environment(\.loadoutService, MockLoadoutService.shared)
    }
}
