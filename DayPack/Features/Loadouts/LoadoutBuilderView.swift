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

    @State private var showInventoryPicker = false

    @State private var name = "Demo Day"
    @State private var selectedDays: Set<Int> = [2, 3, 4, 5, 6]
    @State private var symbol = "backpack.fill"
    @State private var tint: ItemTint = .orange
    @State private var newItemName = ""
    @State private var newItemRequired = true
    @State private var isTemporary = false
    @State private var departureAlertEnabled = false
    @State private var returnAlertEnabled = false
    @State private var departureAlertTime = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: Date()) ?? Date()
    @State private var returnAlertTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var draftItems: [DraftItem] = []

    let onCreate: (String, String, ItemTint, String, [Item], Bool, String?, String?) -> Void

    private let symbolOptions = [
        "backpack.fill", "book.closed.fill", "briefcase.fill",
        "dumbbell.fill", "paperplane.fill", "sparkles",
    ]

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !draftItems.isEmpty
            && (isTemporary || !selectedDays.isEmpty)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    SectionHeader(title: "Loadout details", eyebrow: "Step 1")
                    detailsSection

                    SectionHeader(title: "Timing", eyebrow: "Step 2")
                    timingSection

                    SectionHeader(title: "Items", eyebrow: "Step 3")
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
            .sheet(isPresented: $showInventoryPicker) {
                InventoryPickerSheet(
                    excludedNames: Set(draftItems.map { $0.name.inventoryMatchKey })
                ) { picked in
                    importFromInventory(picked)
                }
            }
        }
    }

    private func importFromInventory(_ items: [InventoryItem]) {
        var existing = Set(draftItems.map { $0.name.inventoryMatchKey })
        for item in items {
            guard existing.insert(item.name.inventoryMatchKey).inserted else { continue }
            draftItems.append(
                DraftItem(
                    name: item.name,
                    symbol: item.symbol,
                    tint: item.tint,
                    isRequired: true
                )
            )
        }
    }

    private var detailsSection: some View {
        VStack(spacing: DPSpacing.md) {
            CustomTextField(label: "Name", text: $name, placeholder: "School Day")
            if !isTemporary {
                WeekdaySelector(selectedDays: $selectedDays)
            }

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

    private var timingSection: some View {
        VStack(spacing: DPSpacing.md) {
            ToggleRow(
                title: "Temporary loadout",
                subtitle: "Tomorrow only",
                isOn: $isTemporary
            )

            DPCard {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    alertToggle(
                        title: "Departure alert",
                        subtitle: departureAlertEnabled ? timeText(departureAlertTime) : "No fixed time",
                        symbol: "bell.fill",
                        isOn: $departureAlertEnabled
                    )
                    if departureAlertEnabled {
                        DatePicker(
                            "Departure time",
                            selection: $departureAlertTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }
            }

            DPCard {
                VStack(alignment: .leading, spacing: DPSpacing.md) {
                    alertToggle(
                        title: "Return alert",
                        subtitle: returnAlertEnabled ? timeText(returnAlertTime) : "No return reminder",
                        symbol: "arrow.uturn.backward.circle.fill",
                        isOn: $returnAlertEnabled
                    )
                    if returnAlertEnabled {
                        DatePicker(
                            "Return time",
                            selection: $returnAlertTime,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
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

                    HStack(spacing: DPSpacing.sm) {
                        SecondaryButton(title: "Add Item", icon: "plus", size: .md) {
                            addItem()
                        }
                        SecondaryButton(title: "From Inventory", icon: "tray.full.fill", size: .md) {
                            showInventoryPicker = true
                        }
                    }
                }
            }

            VStack(spacing: DPSpacing.sm) {
                if draftItems.isEmpty {
                    DPCard {
                        VStack(alignment: .leading, spacing: DPSpacing.sm) {
                            Text("No items yet").dpHeadline()
                            Text("Add items manually or pull regular carry items from Inventory.")
                                .dpCaption()
                                .foregroundStyle(Color.dpInk3)
                            SecondaryButton(title: "From Inventory", icon: "tray.full.fill", size: .md) {
                                showInventoryPicker = true
                            }
                        }
                    }
                } else {
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
    }

    private func addItem() {
        let cleaned = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty,
              !draftItems.contains(where: { $0.name.inventoryMatchKey == cleaned.inventoryMatchKey })
        else { return }

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
        let schedule = WeekdaySchedule.text(from: selectedDays)
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
            isTemporary ? "Temporary" : schedule,
            items,
            isTemporary,
            departureAlertEnabled ? backendTime(departureAlertTime) : nil,
            returnAlertEnabled ? backendTime(returnAlertTime) : nil
        )
        dismiss()
    }

    private func alertToggle(
        title: String,
        subtitle: String,
        symbol: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: DPSpacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.dpOrange)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.dpOrangeSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.dpInk)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.dpInk3)
            }
            Spacer(minLength: DPSpacing.sm)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color.dpOrange)
        }
    }

    private func timeText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func backendTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
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
    LoadoutBuilderView { _, _, _, _, _, _, _, _ in }
}
