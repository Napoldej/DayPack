import SwiftUI

struct InventoryView: View {
    @Environment(\.inventoryStore) private var store
    @State private var searchText: String = ""
    @State private var showCreate = false
    @State private var editing: InventoryItem?
    @State private var selectedCategory = "All"

    private var filtered: [InventoryItem] {
        let q = searchText.lowercased()
        return store.items.filter { item in
            let matchesSearch = searchText.isEmpty || item.name.lowercased().contains(q)
            let matchesCategory = selectedCategory == "All" || category(for: item) == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Library · \(store.items.count) things")
                                .dpEyebrow()
                            Text("Inventory.")
                                .font(.system(size: 38, weight: .bold, design: .serif))
                                .italic()
                                .foregroundStyle(Color.dpInk)
                        }
                        Spacer()
                        Button { showCreate = true } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .black))
                                .foregroundStyle(Color.dpInk)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.dpOrange))
                        }
                        .buttonStyle(PressableButtonStyle())
                        .accessibilityLabel("Add inventory item")
                    }
                    .padding(.horizontal, DPSpacing.lg)
                    .padding(.top, DPSpacing.md)

                    if !store.items.isEmpty {
                        SearchField(text: $searchText, placeholder: "Search inventory")
                            .padding(.horizontal, DPSpacing.lg)
                    }

                    if store.items.isEmpty {
                        EmptyStateView(
                            symbol: "tray",
                            title: "Your inventory is empty",
                            message: "Add the things you regularly carry — wallet, keys, charger.",
                            ctaTitle: "Add your first item",
                            ctaAction: { showCreate = true }
                        )
                    } else {
                        categoryChips
                        smartInsight
                            .padding(.horizontal, DPSpacing.lg)
                        itemList
                            .padding(.horizontal, DPSpacing.lg)
                    }
                }
                .padding(.bottom, 116)
            }
            .background(Color.dpBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.dpBg, for: .navigationBar)
            .sheet(isPresented: $showCreate) {
                InventoryItemEditorView(mode: .create)
            }
            .sheet(item: $editing) { item in
                InventoryItemEditorView(mode: .edit(item))
            }
        }
        .onAppear { store.reload() }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["All", "Tech", "Study", "Health", "Travel"], id: \.self) { category in
                    inventoryChip(category == "All" ? "All · \(store.items.count)" : category, category: category, isSelected: selectedCategory == category)
                }
            }
            .padding(.horizontal, DPSpacing.lg)
        }
    }

    private var smartInsight: some View {
        HStack(spacing: DPSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(Color.dpInk)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Color.dpOrange))
            VStack(alignment: .leading, spacing: 2) {
                Text("Smart insight")
                    .dpEyebrow()
                    .foregroundStyle(Color.dpInk4)
                Text("\(max(store.items.count - 4, 0)) items unused in 30 days")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.dpBg)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                .fill(Color.dpInk)
        )
    }

    private var itemList: some View {
        VStack(spacing: 0) {
            ForEach(Array(filtered.enumerated()), id: \.element.id) { index, item in
                Button { editing = item } label: {
                    HStack(spacing: DPSpacing.md) {
                        IconTile(symbol: item.symbol, tint: item.tint, size: .md)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(.system(size: 15.5, weight: .bold))
                                .foregroundStyle(Color.dpInk)
                                .lineLimit(1)
                            Text("in · inventory")
                                .font(.system(size: 10, weight: .bold))
                                .textCase(.uppercase)
                                .foregroundStyle(Color.dpInk4)
                        }
                        Spacer()
                        Pill(text: category(for: item), style: .neutral)
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(PressableButtonStyle())

                if index < filtered.count - 1 {
                    Divider()
                        .background(Color.dpDivider)
                        .padding(.leading, 52)
                }
            }
        }
    }

    private func inventoryChip(_ title: String, category: String, isSelected: Bool = false) -> some View {
        Button {
            selectedCategory = category
        } label: {
            Text(title)
                .font(.system(size: 12.5, weight: .bold))
                .foregroundStyle(isSelected ? Color.dpBg : Color.dpInk2)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(Capsule().fill(isSelected ? Color.dpInk : .clear))
                .overlay(Capsule().stroke(isSelected ? Color.dpInk : Color.dpDivider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func category(for item: InventoryItem) -> String {
        let key = "\(item.name) \(item.symbol)".lowercased()
        if key.contains("laptop") || key.contains("charger") || key.contains("plug") || key.contains("phone") || key.contains("pods") || key.contains("headphone") || key.contains("battery") {
            return "Tech"
        }
        if key.contains("book") || key.contains("notebook") || key.contains("pen") || key.contains("pencil") || key.contains("study") {
            return "Study"
        }
        if key.contains("water") || key.contains("gym") || key.contains("run") || key.contains("health") || key.contains("shoe") {
            return "Health"
        }
        if key.contains("trip") || key.contains("travel") || key.contains("passport") || key.contains("suitcase") || key.contains("plane") {
            return "Travel"
        }
        return "All"
    }
}

#Preview {
    InventoryView()
}
