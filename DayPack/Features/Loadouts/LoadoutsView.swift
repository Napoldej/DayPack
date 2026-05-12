import SwiftUI

struct LoadoutsView: View {
    @Environment(\.loadoutService) private var service
    @State private var viewModel: LoadoutsViewModel?
    @State private var showBuilder = false
    @State private var showGallery = false
    @State private var editingLoadout: Loadout?
    @State private var selectedFilter = "All"

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
                        }
                    } else {
                        content(vm: vm)
                    }
                }
            }
            .background(Color.dpBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .sheet(isPresented: $showBuilder, onDismiss: {
                Task { await viewModel?.refresh() }
            }) {
                if let vm = viewModel {
                    LoadoutBuilderView { name, symbol, tint, schedule, items, isTemporary, alertTime, returnAlertTime in
                        Task {
                            _ = await vm.createLoadout(
                                name: name, symbol: symbol, tint: tint,
                                schedule: schedule, items: items,
                                isTemporary: isTemporary,
                                alertTime: alertTime, returnAlertTime: returnAlertTime
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
                                name: template.name, symbol: template.symbol, tint: template.tint,
                                schedule: "Manual", items: template.items,
                                isTemporary: false, alertTime: nil, returnAlertTime: nil
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
        ScrollView {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(vm.loadouts.count.formatted(.number.precision(.integerLength(2)))) loadouts")
                            .dpEyebrow()
                        Text("Your loadouts.")
                            .font(.system(size: 38, weight: .bold, design: .serif))
                            .italic()
                            .foregroundStyle(Color.dpInk)
                    }
                    Spacer()
                    Button { showBuilder = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Color.dpInk)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.dpOrange))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .accessibilityLabel("Create loadout")
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.top, DPSpacing.md)

                SearchField(
                    text: Binding(get: { vm.searchText }, set: { vm.searchText = $0 }),
                    placeholder: "Search loadouts"
                )
                .padding(.horizontal, DPSpacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["All", "Daily", "Sports", "Travel", "Conditional"], id: \.self) { filter in
                            filterChip(filter, isSelected: selectedFilter == filter)
                        }
                    }
                    .padding(.horizontal, DPSpacing.lg)
                }

                ForEach(filteredLoadouts(vm)) { loadout in
                    ZStack(alignment: .topTrailing) {
                        LoadoutCard(
                            loadout: loadout,
                            itemCount: vm.itemCount(for: loadout),
                            isActive: loadout.id == vm.todaysID,
                            onTap: { editingLoadout = loadout }
                        )

                        Menu {
                            Button { editingLoadout = loadout } label: {
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
                                .foregroundStyle(Color.dpInk3)
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.dpSurfaceAlt))
                        }
                        .menuStyle(.borderlessButton)
                        .menuOrder(.fixed)
                        .padding(10)
                        .accessibilityLabel("Loadout actions")
                    }
                    .padding(.horizontal, DPSpacing.lg)
                }
            }
            .padding(.bottom, 116)
        }
    }

    private func filteredLoadouts(_ vm: LoadoutsViewModel) -> [Loadout] {
        vm.filtered.filter { loadout in
            switch selectedFilter {
            case "Daily":
                return !loadout.isTemporary && loadout.schedule != "Manual"
            case "Sports":
                return loadout.name.localizedCaseInsensitiveContains("gym")
                    || loadout.name.localizedCaseInsensitiveContains("sport")
                    || loadout.name.localizedCaseInsensitiveContains("run")
            case "Travel":
                return loadout.name.localizedCaseInsensitiveContains("trip")
                    || loadout.name.localizedCaseInsensitiveContains("travel")
                    || loadout.name.localizedCaseInsensitiveContains("weekend")
            case "Conditional":
                return loadout.isTemporary
                    || loadout.name.localizedCaseInsensitiveContains("rain")
                    || loadout.name.localizedCaseInsensitiveContains("conditional")
            default:
                return true
            }
        }
    }

    private func filterChip(_ title: String, isSelected: Bool = false) -> some View {
        Button {
            selectedFilter = title
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isSelected ? Color.dpBg : Color.dpInk2)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.dpInk : .clear)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.dpInk : Color.dpDivider, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Shared Packs Gallery

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
            name: "Minimal Work Pack", symbol: "briefcase.fill", tint: .orange,
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
            name: "Gym Pack", symbol: "dumbbell.fill", tint: .purple,
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
            name: "Student Daily", symbol: "book.closed.fill", tint: .green,
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
            name: "Bangkok Rainy Season", symbol: "cloud.rain.fill", tint: .blue,
            summary: "Fast add-on for wet commutes.",
            items: [
                Item(name: "Umbrella", symbol: "umbrella.fill", tint: .blue, priority: .high, tag: "Always"),
                Item(name: "Light Jacket", symbol: "jacket.fill", tint: .teal),
                Item(name: "Dry Bag", symbol: "bag.fill", tint: .orange),
                Item(name: "Tissues", symbol: "leaf.fill", tint: .green),
            ]
        ),
        SharedPackTemplate(
            name: "Creator Bag", symbol: "camera.fill", tint: .teal,
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
                VStack(spacing: DPSpacing.md) {
                    ForEach(templates) { template in
                        Button { onImport(template) } label: {
                            DPCard {
                                HStack(spacing: DPSpacing.md) {
                                    IconTile(symbol: template.symbol, tint: template.tint, size: .lg)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(Color.dpInk)
                                        Text(template.summary)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundStyle(Color.dpInk3)
                                        Text("\(template.items.count) items")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(Color.dpInk2)
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.dpInk)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(DPSpacing.base)
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
