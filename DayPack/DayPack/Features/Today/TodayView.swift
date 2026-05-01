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
                        onToggle: { vm.togglePacked(for: item) }
                    )
                }
            }

            PrimaryButton(title: "Start Walk-Out Check", icon: "arrow.right") {
                showWalkOut = true
            }
            .padding(.top, DPSpacing.sm)
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.bottom, DPSpacing.xxl)
    }
}

#Preview {
    TodayView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
