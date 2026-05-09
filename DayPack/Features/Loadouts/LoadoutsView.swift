import SwiftUI

struct LoadoutsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?
    @State private var showBuilder = false
    @State private var editingLoadout: Loadout?

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
                Task { await viewModel?.refresh() }
            }) {
                if let vm = viewModel {
                    LoadoutBuilderView { name, symbol, tint, schedule, items, isTemporary, alertTime, returnAlertTime in
                        Task {
                            _ = await vm.createLoadout(
                                name: name,
                                symbol: symbol,
                                tint: tint,
                                schedule: schedule,
                                items: items,
                                isTemporary: isTemporary,
                                alertTime: alertTime,
                                returnAlertTime: returnAlertTime
                            )
                        }
                    }
                }
            }
            .sheet(item: $editingLoadout, onDismiss: {
                Task { await viewModel?.refresh() }
            }) { loadout in
                LoadoutEditorView(loadout: loadout) {
                    Task { await viewModel?.refresh() }
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = LoadoutsViewModel(service: service)
                Task { await viewModel?.refresh() }
            } else {
                Task { await viewModel?.refresh() }
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
                ZStack(alignment: .topTrailing) {
                    LoadoutCard(
                        loadout: loadout,
                        itemCount: vm.itemCount(for: loadout),
                        isActive: loadout.id == vm.todaysID,
                        onTap: { Task { await vm.setToday(loadout) } }
                    )

                    Menu {
                        Button {
                            editingLoadout = loadout
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button {
                            Task { await vm.setToday(loadout) }
                        } label: {
                            Label("Use Today", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            Task { await vm.deleteLoadout(loadout) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.dpInk2)
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.dpBgGrouped))
                    }
                    .menuStyle(.borderlessButton)
                    .menuOrder(.fixed)
                    .padding(10)
                    .accessibilityLabel("Loadout actions")
                }
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
