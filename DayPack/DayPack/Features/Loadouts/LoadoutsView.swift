import SwiftUI

struct LoadoutsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vm = viewModel {
                    if vm.loadouts.isEmpty {
                        EmptyStateView(
                            symbol: "tray",
                            title: "No loadouts yet",
                            message: "Create your first loadout to get personalised packing reminders.",
                            ctaTitle: "Create a loadout",
                            ctaAction: {}
                        )
                    } else {
                        content(vm: vm)
                    }
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Loadouts")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Add new loadout (not wired in v0.1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.dpOrange)
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoadoutsViewModel(service: service)
            }
        }
    }

    @ViewBuilder
    private func content(vm: LoadoutsViewModel) -> some View {
        VStack(spacing: DPSpacing.md) {
            SearchField(
                text: Binding(
                    get: { vm.searchText },
                    set: { vm.searchText = $0 }
                ),
                placeholder: "Search loadouts & items"
            )

            ForEach(vm.filtered) { loadout in
                LoadoutCard(
                    loadout: loadout,
                    itemCount: vm.itemCount(for: loadout),
                    isActive: loadout.id == vm.todaysID
                )
            }
        }
        .padding(.horizontal, DPSpacing.lg)
        .padding(.bottom, DPSpacing.xxl)
    }
}

#Preview {
    LoadoutsView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
