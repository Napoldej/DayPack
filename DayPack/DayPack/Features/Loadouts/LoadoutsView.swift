import SwiftUI

struct LoadoutsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?
    @State private var showBuilder = false

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
                            ctaAction: { showBuilder = true }
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
                        showBuilder = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.dpOrange)
                    }
                }
            }
            .sheet(isPresented: $showBuilder, onDismiss: {
                viewModel?.refresh()
            }) {
                if let vm = viewModel {
                    LoadoutBuilderView { name, symbol, tint, schedule, items in
                        _ = vm.createLoadout(
                            name: name,
                            symbol: symbol,
                            tint: tint,
                            schedule: schedule,
                            items: items
                        )
                    }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoadoutsViewModel(service: service)
            } else {
                viewModel?.refresh()
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
                    isActive: loadout.id == vm.todaysID,
                    onTap: { vm.setToday(loadout) }
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
