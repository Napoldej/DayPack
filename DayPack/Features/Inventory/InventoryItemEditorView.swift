import SwiftUI

struct InventoryItemEditorView: View {
    enum Mode {
        case create
        case edit(InventoryItem)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.inventoryStore) private var store

    let mode: Mode
    @State private var name: String
    @State private var symbol: String
    @State private var tint: ItemTint

    init(mode: Mode) {
        self.mode = mode
        switch mode {
        case .create:
            _name = State(initialValue: "")
            _symbol = State(initialValue: "shippingbox.fill")
            _tint = State(initialValue: .orange)
        case .edit(let existing):
            _name = State(initialValue: existing.name)
            _symbol = State(initialValue: existing.symbol)
            _tint = State(initialValue: existing.tint)
        }
    }

    private var titleText: String {
        if case .edit = mode { return "Edit item" }
        return "New item"
    }

    private var canSave: Bool {
        let key = name.inventoryMatchKey
        guard !key.isEmpty else { return false }
        return !store.items.contains { item in
            guard item.name.inventoryMatchKey == key else { return false }
            if case .edit(let existing) = mode {
                return item.id != existing.id
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    preview
                    nameField
                    iconPicker
                    tintPicker

                    if case .edit(let existing) = mode {
                        SecondaryButton(
                            title: "Delete from inventory",
                            icon: "trash",
                            variant: .danger,
                            size: .md
                        ) {
                            store.delete(existing)
                            dismiss()
                        }
                        .padding(.top, DPSpacing.sm)
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.dpInk2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(canSave ? Color.dpOrange : Color.dpInk4)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var preview: some View {
        DPCard(padding: DPSpacing.lg) {
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: symbol, tint: tint, size: .lg)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name.isEmpty ? "Item name" : name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(name.isEmpty ? Color.dpInk4 : Color.dpInk)
                    Text("Inventory preview")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dpInk3)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var nameField: some View {
        CustomTextField(
            label: "Name",
            text: $name,
            placeholder: "e.g. Notebook, Charger",
            autocapitalization: .words
        )
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: DPSpacing.sm) {
            Text("Icon").dpEyebrow()

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6),
                spacing: 10
            ) {
                ForEach(SymbolCatalog.common, id: \.self) { option in
                    Button { symbol = option } label: {
                        IconTile(symbol: option, tint: option == symbol ? tint : .orange, size: .md)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(option == symbol ? Color.dpOrange : .clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var tintPicker: some View {
        VStack(alignment: .leading, spacing: DPSpacing.sm) {
            Text("Color").dpEyebrow()
            HStack(spacing: 10) {
                ForEach(ItemTint.allCases, id: \.self) { option in
                    Button { tint = option } label: {
                        Circle()
                            .fill(option.foreground)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.dpInk, lineWidth: option == tint ? 2 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch mode {
        case .create:
            store.add(InventoryItem(name: trimmed, symbol: symbol, tint: tint))
        case .edit(let existing):
            store.update(InventoryItem(id: existing.id, name: trimmed, symbol: symbol, tint: tint))
        }
        dismiss()
    }
}

#Preview {
    InventoryItemEditorView(mode: .create)
}
