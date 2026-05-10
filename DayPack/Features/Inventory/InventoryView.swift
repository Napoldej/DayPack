import SwiftUI

struct InventoryView: View {
    @Environment(\.inventoryStore) private var store
    @State private var searchText: String = ""
    @State private var showCreate = false
    @State private var editing: InventoryItem?

    private var filtered: [InventoryItem] {
        guard !searchText.isEmpty else { return store.items }
        let q = searchText.lowercased()
        return store.items.filter { $0.name.lowercased().contains(q) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DPSpacing.md) {
                    if !store.items.isEmpty {
                        SearchField(text: $searchText, placeholder: "Search inventory")
                            .padding(.horizontal, DPSpacing.lg)
                            .padding(.top, DPSpacing.sm)
                    }

                    if store.items.isEmpty {
                        EmptyStateView(
                            symbol: "tray",
                            title: "Your inventory is empty",
                            message: "Add the things you regularly carry — wallet, keys, charger. Once they're here, you can pick them when building any loadout.",
                            ctaTitle: "Add your first item",
                            ctaAction: { showCreate = true }
                        )
                    } else {
                        grid
                            .padding(.horizontal, DPSpacing.lg)
                    }
                }
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("Inventory")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .toolbar {
                if !store.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showCreate = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.dpOrange)
                        }
                    }
                }
            }
            .sheet(isPresented: $showCreate) {
                InventoryItemEditorView(mode: .create)
            }
            .sheet(item: $editing) { item in
                InventoryItemEditorView(mode: .edit(item))
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
                Button { editing = item } label: {
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
                    .dpShadow(.soft)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    InventoryView()
}
