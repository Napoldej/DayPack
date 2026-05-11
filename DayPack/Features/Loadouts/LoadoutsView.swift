import SwiftUI

struct LoadoutsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?
    @State private var showBuilder = false
    @State private var showGallery = false
    @State private var editingLoadout: Loadout?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    if vm.loadouts.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                symbol: "tray",
                                title: "No loadouts yet",
                                message: "Create your first loadout to get personalised packing reminders.",
                                ctaTitle: "Create a loadout",
                                ctaAction: { showBuilder = true }
                            )
                            .padding(.horizontal, DPSpacing.lg)
                        }
                    } else {
                        content(vm: vm)
                    }
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Loadouts")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showGallery = true
                    } label: {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.dpInk2)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurfaceAlt))
                    }
                    .accessibilityLabel("Shared packs gallery")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBuilder = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpOrange))
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
            .sheet(isPresented: $showGallery, onDismiss: {
                Task { await viewModel?.refresh() }
            }) {
                if let vm = viewModel {
                    SharedPacksGalleryView { template in
                        Task {
                            await vm.createLoadout(
                                name: template.name,
                                symbol: template.symbol,
                                tint: template.tint,
                                schedule: "Manual",
                                items: template.items,
                                isTemporary: false,
                                alertTime: nil,
                                returnAlertTime: nil
                            )
                            showGallery = false
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
        List {
            SearchField(
                text: Binding(
                    get: { vm.searchText },
                    set: { vm.searchText = $0 }
                ),
                placeholder: "Search loadouts & items"
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: DPSpacing.md, leading: DPSpacing.lg, bottom: DPSpacing.sm, trailing: DPSpacing.lg))
            .listRowBackground(Color.dpBg)

            ForEach(vm.filtered) { loadout in
                loadoutRow(loadout, vm: vm)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: DPSpacing.sm, leading: DPSpacing.lg, bottom: DPSpacing.sm, trailing: DPSpacing.lg))
                    .listRowBackground(Color.dpBg)
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            Task { await vm.setToday(loadout) }
                        } label: {
                            Label("Today", systemImage: "checkmark.circle.fill")
                        }
                        .tint(Color.dpOrange)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await vm.deleteLoadout(loadout) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func loadoutRow(_ loadout: Loadout, vm: LoadoutsViewModel) -> some View {
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
                    .frame(width: 30, height: 30)
                    .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurfaceAlt))
                    .overlay(
                        RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                            .stroke(Color.dpDivider, lineWidth: 1)
                    )
            }
            .menuStyle(.borderlessButton)
            .menuOrder(.fixed)
            .padding(10)
            .accessibilityLabel("Loadout actions")
        }
    }
}

private struct SharedPackTemplate: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
    let tint: ItemTint
    let summary: String
    let items: [Item]
}

private struct SharedPacksGalleryView: View {
    @Environment(\.dismiss) private var dismiss
    let onImport: (SharedPackTemplate) -> Void

    private let templates: [SharedPackTemplate] = [
        SharedPackTemplate(
            name: "Minimal Work Pack",
            symbol: "briefcase.fill",
            tint: .orange,
            summary: "Lean office carry for laptop days.",
            items: [
                Item(name: "Laptop", symbol: "laptopcomputer", tint: .purple, priority: .high, tag: "Always"),
                Item(name: "Charger", symbol: "powerplug.fill", tint: .green, priority: .high, tag: "Always"),
                Item(name: "Badge", symbol: "person.text.rectangle.fill", tint: .orange, priority: .high, tag: "Always"),
                Item(name: "Notebook", symbol: "book.closed.fill", tint: .green),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue),
            ]
        ),
        SharedPackTemplate(
            name: "Gym Pack",
            symbol: "dumbbell.fill",
            tint: .purple,
            summary: "After-work gym essentials.",
            items: [
                Item(name: "Gym Shoes", symbol: "shoeprints.fill", tint: .green, priority: .high, tag: "Always"),
                Item(name: "Gym Clothes", symbol: "tshirt.fill", tint: .blue, priority: .high, tag: "Always"),
                Item(name: "Towel", symbol: "square.fill", tint: .teal),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue),
                Item(name: "Protein Shake", symbol: "drop.halffull", tint: .red, tag: "Optional"),
            ]
        ),
        SharedPackTemplate(
            name: "Student Daily",
            symbol: "book.closed.fill",
            tint: .green,
            summary: "Class day basics without overpacking.",
            items: [
                Item(name: "Notebook", symbol: "book.closed.fill", tint: .green, priority: .high, tag: "Always"),
                Item(name: "Laptop", symbol: "laptopcomputer", tint: .purple),
                Item(name: "Charger", symbol: "powerplug.fill", tint: .green, priority: .high, tag: "Always"),
                Item(name: "Pen", symbol: "pencil", tint: .orange),
                Item(name: "Water Bottle", symbol: "drop.fill", tint: .blue),
            ]
        ),
        SharedPackTemplate(
            name: "Bangkok Rainy Season",
            symbol: "cloud.rain.fill",
            tint: .blue,
            summary: "Fast add-on for wet commutes.",
            items: [
                Item(name: "Umbrella", symbol: "umbrella.fill", tint: .blue, priority: .high, tag: "Always"),
                Item(name: "Light Jacket", symbol: "jacket.fill", tint: .teal),
                Item(name: "Dry Bag", symbol: "bag.fill", tint: .orange),
                Item(name: "Tissues", symbol: "leaf.fill", tint: .green),
            ]
        ),
        SharedPackTemplate(
            name: "Creator Bag",
            symbol: "camera.fill",
            tint: .teal,
            summary: "Small shoot kit for cafe or street days.",
            items: [
                Item(name: "Camera", symbol: "camera.fill", tint: .teal, priority: .high, tag: "Always"),
                Item(name: "Battery", symbol: "battery.100percent", tint: .green, priority: .high, tag: "Always"),
                Item(name: "Memory Card", symbol: "sdcard.fill", tint: .orange, priority: .high, tag: "Always"),
                Item(name: "Lens Cloth", symbol: "sparkles", tint: .blue),
            ]
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    ForEach(templates) { template in
                        Button {
                            onImport(template)
                        } label: {
                            DPCard {
                                HStack(spacing: DPSpacing.md) {
                                    IconTile(symbol: template.symbol, tint: template.tint, size: .md)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color.dpInk)
                                        Text(template.summary)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color.dpInk3)
                                        Text("\(template.items.count) items")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color.dpOrange)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color.dpOrange)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(DPSpacing.lg)
            }
            .background(Color.dpBg)
            .navigationTitle("Shared Packs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color.dpInk2)
                }
            }
        }
    }
}

#Preview {
    LoadoutsView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
