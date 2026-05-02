import SwiftUI

struct LoadoutBuilderView: View {
    struct DraftItem: Identifiable {
        let id = UUID()
        var name: String
        var symbol: String
        var tint: ItemTint
        var isRequired: Bool
    }

    @Environment(\.dismiss) private var dismiss

    @State private var name = "Demo Day"
    @State private var schedule = "Today"
    @State private var symbol = "backpack.fill"
    @State private var tint: ItemTint = .orange
    @State private var newItemName = ""
    @State private var newItemRequired = true
    @State private var draftItems: [DraftItem] = [
        DraftItem(name: "Wallet", symbol: "wallet.pass.fill", tint: .orange, isRequired: true),
        DraftItem(name: "Keys", symbol: "key.fill", tint: .orange, isRequired: true),
        DraftItem(name: "Water Bottle", symbol: "drop.fill", tint: .blue, isRequired: false),
    ]

    let onCreate: (String, String, ItemTint, String, [Item]) -> Void

    private let symbolOptions = [
        "backpack.fill", "book.closed.fill", "briefcase.fill",
        "dumbbell.fill", "paperplane.fill", "sparkles",
    ]

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !draftItems.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    SectionHeader(title: "Loadout details", eyebrow: "Step 1")
                    detailsSection

                    SectionHeader(title: "Items", eyebrow: "Step 2")
                    itemsSection

                    PrimaryButton(
                        title: "Create and Use Today",
                        icon: "checkmark",
                        isDisabled: !canCreate
                    ) {
                        create()
                    }
                    .padding(.top, DPSpacing.sm)
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("New Loadout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.dpInk2)
                }
            }
        }
    }

    private var detailsSection: some View {
        VStack(spacing: DPSpacing.md) {
            CustomTextField(label: "Name", text: $name, placeholder: "School Day")
            CustomTextField(label: "Schedule", text: $schedule, placeholder: "Today")

            DPCard {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    Text("Style").dpEyebrow().foregroundStyle(Color.dpInk3)

                    HStack(spacing: DPSpacing.md) {
                        Menu {
                            ForEach(symbolOptions, id: \.self) { option in
                                Button {
                                    symbol = option
                                } label: {
                                    Label(option, systemImage: option)
                                }
                            }
                        } label: {
                            IconTile(symbol: symbol, tint: tint, size: .lg)
                        }

                        Picker("Color", selection: $tint) {
                            ForEach(ItemTint.allCases, id: \.self) { tint in
                                Text(tint.rawValue.capitalized).tag(tint)
                            }
                        }
                        .pickerStyle(.menu)

                        Spacer()
                    }
                }
            }
        }
    }

    private var itemsSection: some View {
        VStack(spacing: DPSpacing.md) {
            DPCard {
                VStack(spacing: DPSpacing.md) {
                    CustomTextField(label: "Item name", text: $newItemName, placeholder: "Laptop")

                    ToggleRow(
                        title: "Required before leaving",
                        subtitle: "Required items block the final Walk-Out button.",
                        isOn: $newItemRequired
                    )

                    SecondaryButton(title: "Add Item", icon: "plus", size: .md) {
                        addItem()
                    }
                }
            }

            VStack(spacing: DPSpacing.sm) {
                ForEach(draftItems) { item in
                    HStack(spacing: DPSpacing.md) {
                        IconTile(symbol: item.symbol, tint: item.tint, size: .md)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name).dpHeadline()
                            Text(item.isRequired ? "Required" : "Optional")
                                .dpCaption()
                                .foregroundStyle(Color.dpInk3)
                        }
                        Spacer()
                        Button {
                            removeItem(item)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color.dpInk4)
                        }
                    }
                    .padding(DPSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                            .fill(Color.dpSurface)
                    )
                }
            }
        }
    }

    private func addItem() {
        let cleaned = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        draftItems.append(
            DraftItem(
                name: cleaned,
                symbol: symbolForItem(named: cleaned),
                tint: newItemRequired ? .orange : .blue,
                isRequired: newItemRequired
            )
        )
        newItemName = ""
        newItemRequired = true
    }

    private func removeItem(_ item: DraftItem) {
        draftItems.removeAll { $0.id == item.id }
    }

    private func create() {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedSchedule = schedule.trimmingCharacters(in: .whitespacesAndNewlines)
        let items = draftItems.map { draft in
            Item(
                name: draft.name,
                symbol: draft.symbol,
                tint: draft.tint,
                priority: draft.isRequired ? .high : .normal,
                tag: draft.isRequired ? "Always" : "Optional"
            )
        }

        onCreate(
            cleanedName,
            symbol,
            tint,
            cleanedSchedule.isEmpty ? "Manual" : cleanedSchedule,
            items
        )
        dismiss()
    }

    private func symbolForItem(named name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("key") { return "key.fill" }
        if lower.contains("wallet") { return "wallet.pass.fill" }
        if lower.contains("water") { return "drop.fill" }
        if lower.contains("laptop") { return "laptopcomputer" }
        if lower.contains("book") || lower.contains("notebook") { return "book.closed.fill" }
        if lower.contains("charger") { return "powerplug.fill" }
        if lower.contains("shoe") { return "shoeprints.fill" }
        if lower.contains("headphone") || lower.contains("earbud") { return "headphones" }
        return "checklist"
    }
}

#Preview {
    LoadoutBuilderView { _, _, _, _, _ in }
}
