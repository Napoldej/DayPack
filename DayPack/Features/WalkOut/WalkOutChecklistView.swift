import SwiftUI

struct WalkOutChecklistView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.loadoutService) private var service
    @State private var viewModel: TodayViewModel?
    @State private var showSuccess = false
    @State private var completedCount = 0

    private var allRequiredPacked: Bool {
        guard let vm = viewModel else { return false }
        let required = vm.items.filter { $0.priority == .high || $0.tag == "Always" }
        return required.allSatisfy { item in
            vm.entry(for: item)?.isPacked == true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let vm = viewModel {
                ScrollView {
                    VStack(spacing: DPSpacing.lg) {
                        ProgressRing(
                            value: vm.progress,
                            size: 140,
                            lineWidth: 10,
                            label: "\(vm.packedCount) / \(vm.totalCount)"
                        )
                        .padding(.top, DPSpacing.lg)

                        section(title: "Essentials", eyebrow: "Always",   items: vm.items.filter { $0.tag == "Always" }, vm: vm)
                        section(title: "Loadout",    eyebrow: "Today",    items: vm.items.filter { $0.tag != "Always" && $0.tag != "Optional" }, vm: vm)
                        section(title: "Optional",   eyebrow: "Nice-to-have", items: vm.items.filter { $0.tag == "Optional" }, vm: vm)
                    }
                    .padding(.horizontal, DPSpacing.lg)
                    .padding(.bottom, DPSpacing.xl)
                }
                .background(Color.dpBg)

                VStack(spacing: 0) {
                    Divider().background(Color.dpHairline)
                    PrimaryButton(
                        title: allRequiredPacked ? "I'm Ready to Go" : "Pack required items first",
                        icon: allRequiredPacked ? "checkmark" : nil,
                        isDisabled: !allRequiredPacked
                    ) {
                        Task {
                            completedCount = vm.packedCount
                            await vm.completeCheck()
                            showSuccess = true
                        }
                    }
                    .padding(.horizontal, DPSpacing.lg)
                    .padding(.vertical, DPSpacing.md)
                }
                .background(Color.dpBg)
            }
        }
        .navigationTitle("Walk-Out Check")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.dpInk2)
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
        }
        .fullScreenCover(isPresented: $showSuccess) {
            PerfectDepartureView(packedCount: completedCount) {
                showSuccess = false
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func section(title: String, eyebrow: String, items: [Item], vm: TodayViewModel) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                let packedInGroup = items.filter { vm.entry(for: $0)?.isPacked == true }.count
                SectionHeader(
                    title: title,
                    eyebrow: "\(eyebrow) · \(packedInGroup)/\(items.count)"
                )
                VStack(spacing: DPSpacing.sm) {
                    ForEach(items) { item in
                        ChecklistItemRow(
                            item: item,
                            isPacked: vm.entry(for: item)?.isPacked ?? false,
                            onToggle: { Task { await vm.togglePacked(for: item) } }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        WalkOutChecklistView()
            .environment(\.loadoutService, MockLoadoutService.shared)
    }
}
