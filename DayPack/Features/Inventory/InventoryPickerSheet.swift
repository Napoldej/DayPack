import SwiftUI

struct InventoryPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.inventoryStore) private var store

    let excludedNames: Set<String>
    let onPick: ([InventoryItem]) -> Void

    @State private var selected: Set<UUID> = []
    @State private var searchText: String = ""

    private var filtered: [InventoryItem] {
        let pool = store.items.filter { !excludedNames.contains($0.name.lowercased()) }
        guard !searchText.isEmpty else { return pool }
        let q = searchText.lowercased()
        return pool.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    EmptyStateView(
                        symbol: "tray",
                        title: "Inventory is empty",
                        message: "Open the Inventory tab to add the items you regularly carry. They'll show up here next time."
                    )
                } else if filtered.isEmpty {
                    EmptyStateView(
                        symbol: "checkmark.seal",
                        title: "All caught up",
                        message: "Every inventory item is already in this loadout, or no items match your search."
                    )
                } else {
                    ScrollView {
                        VStack(spacing: DPSpacing.md) {
                            SearchField(text: $searchText, placeholder: "Search inventory")
                            grid
                        }
                        .padding(.horizontal, DPSpacing.lg)
                        .padding(.bottom, DPSpacing.xxl)
                    }
                }
            }
            .background(Color.dpBg)
            .navigationTitle("Pick items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.dpInk2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add (\(selected.count))") {
                        let picked = store.items.filter { selected.contains($0.id) }
                        onPick(picked)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(selected.isEmpty ? Color.dpInk4 : Color.dpOrange)
                    .disabled(selected.isEmpty)
                }
            }
        }
        .onAppear { store.reload() }
    }

    private var grid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: DPSpacing.md), count: 3),
            spacing: DPSpacing.md
        ) {
            ForEach(filtered) { item in
                Button { toggle(item) } label: {
                    VStack(spacing: DPSpacing.sm) {
                        IconTile(symbol: item.symbol, tint: item.tint, size: .lg)
                        Text(item.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.dpInk)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DPSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                            .fill(Color.dpSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                            .stroke(selected.contains(item.id) ? Color.dpOrange : .clear, lineWidth: 2)
                    )
                    .dpShadow(.soft)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ item: InventoryItem) {
        if selected.contains(item.id) {
            selected.remove(item.id)
        } else {
            selected.insert(item.id)
        }
    }
}
