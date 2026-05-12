import SwiftUI

struct LoadoutEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.loadoutService) private var service

    let loadout: Loadout
    var onDone: () -> Void

    @State private var name: String
    @State private var selectedDays: Set<Int>
    @State private var symbol: String
    @State private var tint: ItemTint
    @State private var isTemporary: Bool
    @State private var departureAlertEnabled: Bool
    @State private var returnAlertEnabled: Bool
    @State private var departureAlertTime: Date
    @State private var returnAlertTime: Date
    @State private var items: [Item] = []
    @State private var newItemName = ""
    @State private var showItemManager = false
    @State private var errorMessage: String?

    init(loadout: Loadout, onDone: @escaping () -> Void) {
        self.loadout = loadout
        self.onDone = onDone
        _name = State(initialValue: loadout.name)
        _selectedDays = State(initialValue: Set(loadout.scheduledDays))
        _symbol = State(initialValue: loadout.symbol)
        _tint = State(initialValue: loadout.tint)
        _isTemporary = State(initialValue: loadout.isTemporary)
        _departureAlertEnabled = State(initialValue: loadout.alertTime != nil)
        _returnAlertEnabled = State(initialValue: loadout.returnAlertTime != nil)
        _departureAlertTime = State(initialValue: Self.date(from: loadout.alertTime, fallbackHour: 7, fallbackMinute: 30))
        _returnAlertTime = State(initialValue: Self.date(from: loadout.returnAlertTime, fallbackHour: 18, fallbackMinute: 0))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    SectionHeader(title: "Details", eyebrow: "Loadout")
                    CustomTextField(label: "Name", text: $name, placeholder: "School Day")
                    if !isTemporary {
                        WeekdaySelector(selectedDays: $selectedDays)
                    }

                    ToggleRow(title: "Temporary loadout", subtitle: "Tomorrow only", isOn: $isTemporary)
                    alertRow(title: "Departure alert", enabled: $departureAlertEnabled, time: $departureAlertTime)
                    alertRow(title: "Return alert", enabled: $returnAlertEnabled, time: $returnAlertTime)

                    SectionHeader(title: "Items", eyebrow: "\(items.count) total")
                    itemSummary

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.dpRed)
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("Edit Loadout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.dpInk2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.dpInk)
                }
            }
        }
        .task { await loadItems() }
        .sheet(isPresented: $showItemManager) {
            LoadoutItemManagerView(
                loadout: loadout,
                items: $items,
                newItemName: $newItemName
            )
        }
    }

    private var itemSummary: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                ForEach(items.prefix(4)) { item in
                    HStack(spacing: DPSpacing.sm) {
                        Image(systemName: item.tag == "Optional" ? "circle" : "checkmark.circle.fill")
                            .foregroundStyle(item.tag == "Optional" ? Color.dpInk4 : Color.dpInk)
                        Text(item.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dpInk)
                        Spacer()
                    }
                }
                if items.count > 4 {
                    Text("+ \(items.count - 4) more")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                }
                SecondaryButton(title: "Manage Items", icon: "list.bullet", size: .md) {
                    showItemManager = true
                }
            }
        }
    }

    private func alertRow(title: String, enabled: Binding<Bool>, time: Binding<Date>) -> some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                ToggleRow(title: title, subtitle: enabled.wrappedValue ? backendTime(time.wrappedValue) : "Off", isOn: enabled)
                if enabled.wrappedValue {
                    DatePicker(title, selection: time, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }
            }
        }
    }

    private func loadItems() async {
        do {
            items = try await service.items(in: loadout).sorted { $0.order < $1.order }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save() async {
        do {
            _ = try await service.updateLoadout(
                loadout,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                symbol: symbol,
                tint: tint,
                schedule: isTemporary ? "Temporary" : WeekdaySchedule.text(from: selectedDays),
                isTemporary: isTemporary,
                alertTime: departureAlertEnabled ? backendTime(departureAlertTime) : nil,
                returnAlertTime: returnAlertEnabled ? backendTime(returnAlertTime) : nil
            )
            for index in items.indices {
                items[index].order = index + 1
                _ = try await service.updateItem(items[index])
            }
            onDone()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func backendTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private static func date(from time: String?, fallbackHour: Int, fallbackMinute: Int) -> Date {
        let calendar = Calendar.current
        guard let time else {
            return calendar.date(bySettingHour: fallbackHour, minute: fallbackMinute, second: 0, of: Date()) ?? Date()
        }
        let parts = time.split(separator: ":").compactMap { Int($0) }
        return calendar.date(bySettingHour: parts.first ?? fallbackHour, minute: parts.dropFirst().first ?? fallbackMinute, second: 0, of: Date()) ?? Date()
    }

    static func symbolForItem(named name: String) -> String {
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

private struct LoadoutItemManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.loadoutService) private var service

    let loadout: Loadout
    @Binding var items: [Item]
    @Binding var newItemName: String
    @State private var errorMessage: String?
    @State private var showInventoryPicker = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: DPSpacing.sm) {
                        TextField("Add item", text: $newItemName)
                            .font(.system(size: 16, weight: .semibold))
                            .submitLabel(.done)
                            .onSubmit {
                                Task { await addItem() }
                            }
                        Button {
                            Task { await addItem() }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color.dpInk)
                        }
                        .buttonStyle(.plain)
                    }
                    Button {
                        showInventoryPicker = true
                    } label: {
                        Label("From Inventory", systemImage: "tray.full.fill")
                    }
                    .foregroundStyle(Color.dpInk)
                }

                Section {
                    ForEach($items) { $item in
                        HStack(spacing: DPSpacing.md) {
                            Button {
                                toggleRequired(&item)
                            } label: {
                                Image(systemName: item.tag == "Optional" ? "circle" : "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(item.tag == "Optional" ? Color.dpInk4 : Color.dpInk)
                            }
                            .buttonStyle(.plain)

                            TextField("Item", text: $item.name)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .onMove { source, destination in
                        items.move(fromOffsets: source, toOffset: destination)
                    }
                    .onDelete { indexes in
                        Task { await deleteItems(at: indexes) }
                    }
                } header: {
                    Text("Items")
                } footer: {
                    Text("Drag to reorder. Swipe left to delete.")
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(Color.dpRed)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Manage Items")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showInventoryPicker) {
                InventoryPickerSheet(
                    excludedNames: Set(items.map { $0.name.inventoryMatchKey })
                ) { picked in
                    Task { await importFromInventory(picked) }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addItem() async {
        let cleaned = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty,
              !items.contains(where: { $0.name.inventoryMatchKey == cleaned.inventoryMatchKey })
        else { return }
        do {
            let item = try await service.addItem(
                to: loadout,
                item: Item(
                    name: cleaned,
                    symbol: LoadoutEditorView.symbolForItem(named: cleaned),
                    tint: .orange,
                    priority: .high,
                    tag: "Always",
                    order: items.count + 1
                )
            )
            items.append(item)
            newItemName = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importFromInventory(_ picked: [InventoryItem]) async {
        var existing = Set(items.map { $0.name.inventoryMatchKey })
        do {
            for inventoryItem in picked where existing.insert(inventoryItem.name.inventoryMatchKey).inserted {
                let item = try await service.addItem(
                    to: loadout,
                    item: Item(
                        name: inventoryItem.name,
                        symbol: inventoryItem.symbol,
                        tint: inventoryItem.tint,
                        priority: .high,
                        tag: "Always",
                        order: items.count + 1
                    )
                )
                items.append(item)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deleteItems(at indexes: IndexSet) async {
        let targets = indexes.compactMap { items.indices.contains($0) ? items[$0] : nil }
        do {
            for item in targets {
                try await service.deleteItem(id: item.id, from: loadout)
            }
            items.removeAll { item in targets.contains(where: { $0.id == item.id }) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func toggleRequired(_ item: inout Item) {
        let required = item.tag == "Optional"
        item.priority = required ? .high : .normal
        item.tag = required ? "Always" : "Optional"
        item.tint = required ? .orange : .blue
    }
}
