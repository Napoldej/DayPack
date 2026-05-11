import SwiftUI
import UIKit

struct TripPlannerView: View {
    struct TripItem: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var symbol: String
        var tint: ItemTint
        var isPacked: Bool

        init(
            id: UUID = UUID(),
            name: String,
            symbol: String,
            tint: ItemTint = .orange,
            isPacked: Bool = false
        ) {
            self.id = id
            self.name = name
            self.symbol = symbol
            self.tint = tint
            self.isPacked = isPacked
        }
    }

    struct TripBag: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var items: [TripItem]

        init(id: UUID = UUID(), name: String, items: [TripItem] = []) {
            self.id = id
            self.name = name
            self.items = items
        }
    }

    private struct LegacyTripBag: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var items: String
    }

    @Environment(\.apiClient) private var api
    @Environment(\.authSession) private var session
    @Environment(\.loadoutService) private var service
    @AppStorage("tripPlanner.name") private var tripName = "Weekend Trip"
    @AppStorage("tripPlanner.bags") private var bagsData = ""

    @State private var bags: [TripBag] = [
        TripBag(
            name: "Carry-on",
            items: [
                TripItem(name: "Wallet", symbol: "wallet.pass.fill", tint: .orange),
                TripItem(name: "Keys", symbol: "key.fill", tint: .orange),
                TripItem(name: "Water Bottle", symbol: "drop.fill", tint: .blue),
            ]
        ),
        TripBag(
            name: "Suitcase",
            items: [
                TripItem(name: "Clothes", symbol: "tshirt.fill", tint: .blue),
                TripItem(name: "Charger", symbol: "powerplug.fill", tint: .green),
                TripItem(name: "Toothbrush", symbol: "mouth.fill", tint: .teal),
            ]
        ),
    ]
    @State private var newBagName = ""
    @State private var availableLoadouts: [Loadout] = []
    @State private var friendCode = ""
    @State private var friendPreview: TripShareCodePreview?
    @State private var statusMessage: String?
    @State private var errorMessage: String?
    @State private var inventoryTargetBagID: UUID?

    private var packedCount: Int {
        bags.flatMap(\.items).filter(\.isPacked).count
    }

    private var totalCount: Int {
        bags.flatMap(\.items).count
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(packedCount) / Double(totalCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    SectionHeader(title: "Trip", eyebrow: "Pack once before leaving")
                    tripSummary

                    if !availableLoadouts.isEmpty {
                        SectionHeader(title: "Add Packs", eyebrow: "From loadouts")
                        loadoutImportSection
                    }

                    SectionHeader(title: "Friend Code", eyebrow: "Import pack")
                    friendCodeSection

                    if let friendPreview {
                        friendPreviewCard(friendPreview)
                    }

                    if let statusMessage {
                        messageRow(statusMessage, color: Color.dpGreen)
                    }

                    if let errorMessage {
                        messageRow(errorMessage, color: Color.dpRed)
                    }

                    SectionHeader(title: "Trip Sections", eyebrow: "\(bags.count) bags")
                    VStack(spacing: DPSpacing.md) {
                        ForEach(bags) { bag in
                            bagSection(bag)
                        }
                    }

                    DPCard {
                        VStack(spacing: DPSpacing.md) {
                            CustomTextField(label: "New section", text: $newBagName, placeholder: "Tech pouch")
                            SecondaryButton(title: "Add Section", icon: "plus", size: .md) {
                                addBag()
                            }
                        }
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("Trip Planner")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
        }
        .sheet(item: inventorySheetBinding) { bag in
            InventoryPickerSheet(excludedNames: Set(bag.items.map(\.name))) { picked in
                addInventoryItems(picked, to: bag.id)
            }
        }
        .onAppear {
            loadBags()
            Task { await loadAvailableLoadouts() }
        }
        .onChange(of: bags) { _, _ in saveBags() }
    }

    private var inventorySheetBinding: Binding<TripBag?> {
        Binding(
            get: {
                guard let inventoryTargetBagID else { return nil }
                return bags.first { $0.id == inventoryTargetBagID }
            },
            set: { bag in
                inventoryTargetBagID = bag?.id
            }
        )
    }

    private var tripSummary: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                CustomTextField(label: "Trip name", text: $tripName, placeholder: "Weekend Trip")
                ProgressBar(
                    value: progress,
                    size: .lg,
                    label: "\(packedCount) of \(totalCount) packed",
                    trailingLabel: "\(Int(progress * 100))%"
                )
            }
        }
    }

    private var loadoutImportSection: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                Text("Import a saved pack as a trip section, then adjust the items from Inventory.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.dpInk3)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DPSpacing.sm) {
                        ForEach(availableLoadouts) { loadout in
                            Button {
                                Task { await importLoadout(loadout) }
                            } label: {
                                HStack(spacing: 8) {
                                    IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .sm)
                                    Text(loadout.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color.dpInk)
                                        .lineLimit(1)
                                }
                                .padding(.horizontal, 10)
                                .frame(height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                                        .fill(Color.dpSurfaceAlt)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                                                .stroke(Color.dpDivider, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var friendCodeSection: some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                Text("Import a friend's pack into this trip.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.dpInk3)

                CustomTextField(
                    label: "Code",
                    text: $friendCode,
                    placeholder: "PACK-7K2P",
                    autocapitalization: .characters,
                    disableAutocorrection: true
                )

                HStack(spacing: DPSpacing.sm) {
                    SecondaryButton(title: "Preview", icon: "eye", size: .md) {
                        Task { await previewFriendPack() }
                    }
                    SecondaryButton(title: "Import", icon: "tray.and.arrow.down.fill", size: .md) {
                        Task { await importFriendPack() }
                    }
                }
            }
        }
    }

    private func friendPreviewCard(_ preview: TripShareCodePreview) -> some View {
        DPCard {
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: preview.loadout.icon ?? "backpack.fill", tint: .orange, size: .md)
                VStack(alignment: .leading, spacing: 4) {
                    Text(preview.loadout.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.dpInk)
                    Text("\(preview.loadout.items.count) items ready to import")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                }
                Spacer()
                Pill(text: preview.code, style: .info)
            }
        }
    }

    private func bagSection(_ bag: TripBag) -> some View {
        DPCard {
            VStack(alignment: .leading, spacing: DPSpacing.md) {
                HStack(spacing: DPSpacing.md) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(bag.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(Color.dpInk)
                        Text("\(bag.items.filter(\.isPacked).count) of \(bag.items.count) packed")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.dpInk3)
                    }
                    Spacer()
                    Button {
                        removeBag(bag)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.dpRed)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.dpRedSoft))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(bag.name)")
                }

                if bag.items.isEmpty {
                    Text("No items yet.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.dpInk3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, DPSpacing.sm)
                } else {
                    VStack(spacing: DPSpacing.sm) {
                        ForEach(bag.items) { item in
                            tripItemRow(item, in: bag)
                        }
                    }
                }

                SecondaryButton(title: "Add from Inventory", icon: "tray.full.fill", size: .md) {
                    inventoryTargetBagID = bag.id
                }
            }
        }
    }

    private func tripItemRow(_ item: TripItem, in bag: TripBag) -> some View {
        Button {
            toggleItem(item, in: bag)
        } label: {
            HStack(spacing: DPSpacing.md) {
                Image(systemName: item.isPacked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(item.isPacked ? Color.dpGreen : Color.dpInk4)
                IconTile(symbol: item.symbol, tint: item.tint, size: .sm)
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(item.isPacked ? Color.dpInk3 : Color.dpInk)
                    .strikethrough(item.isPacked, color: Color.dpInk4)
                Spacer()
                Button {
                    removeItem(item, from: bag)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.dpInk4)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove \(item.name)")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                    .fill(Color.dpSurfaceAlt)
            )
        }
        .buttonStyle(.plain)
    }

    private func addBag() {
        let cleaned = newBagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        bags.append(TripBag(name: cleaned))
        newBagName = ""
        notifySuccess()
    }

    private func removeBag(_ bag: TripBag) {
        bags.removeAll { $0.id == bag.id }
        notifyTap()
    }

    private func toggleItem(_ item: TripItem, in bag: TripBag) {
        guard let bagIndex = bags.firstIndex(where: { $0.id == bag.id }),
              let itemIndex = bags[bagIndex].items.firstIndex(where: { $0.id == item.id })
        else { return }
        bags[bagIndex].items[itemIndex].isPacked.toggle()
        notifyTap()
    }

    private func removeItem(_ item: TripItem, from bag: TripBag) {
        guard let bagIndex = bags.firstIndex(where: { $0.id == bag.id }) else { return }
        bags[bagIndex].items.removeAll { $0.id == item.id }
        notifyTap()
    }

    private func addInventoryItems(_ picked: [InventoryItem], to bagID: UUID) {
        guard let bagIndex = bags.firstIndex(where: { $0.id == bagID }) else { return }
        var existing = Set(bags[bagIndex].items.map { $0.name.inventoryMatchKey })
        for item in picked where existing.insert(item.name.inventoryMatchKey).inserted {
            bags[bagIndex].items.append(
                TripItem(name: item.name, symbol: item.symbol, tint: item.tint)
            )
        }
        notifySuccess()
    }

    private func loadBags() {
        guard let data = bagsData.data(using: .utf8) else { return }
        if let decoded = try? JSONDecoder().decode([TripBag].self, from: data), !decoded.isEmpty {
            bags = decoded
            return
        }
        if let legacy = try? JSONDecoder().decode([LegacyTripBag].self, from: data), !legacy.isEmpty {
            bags = legacy.map { old in
                TripBag(
                    id: old.id,
                    name: old.name,
                    items: old.items
                        .split(whereSeparator: \.isNewline)
                        .map { line in
                            let name = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                            return TripItem(name: name, symbol: symbolForItem(named: name))
                        }
                )
            }
            saveBags()
        }
    }

    private func saveBags() {
        guard let data = try? JSONEncoder().encode(bags),
              let string = String(data: data, encoding: .utf8)
        else { return }
        bagsData = string
    }

    private func loadAvailableLoadouts() async {
        do {
            availableLoadouts = try await service.allLoadouts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importLoadout(_ loadout: Loadout) async {
        do {
            let loadoutItems = try await service.items(in: loadout)
            bags.append(
                TripBag(
                    name: loadout.name,
                    items: loadoutItems.map {
                        TripItem(name: $0.name, symbol: $0.symbol, tint: $0.tint)
                    }
                )
            )
            statusMessage = "\(loadout.name) added to this trip"
            errorMessage = nil
            notifySuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func previewFriendPack() async {
        clearMessages()
        do {
            friendPreview = try await api.get("/share-codes/\(normalizedFriendCode())")
            notifyTap()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func importFriendPack() async {
        guard let userID = session.currentUser?.id else {
            errorMessage = "Sign in to import a friend's pack."
            return
        }
        clearMessages()
        do {
            let imported: TripSharingLoadoutDTO = try await api.post(
                "/share-codes/\(normalizedFriendCode())/import",
                body: TripEmptyBody(),
                query: [URLQueryItem(name: "userID", value: userID.uuidString)]
            )
            bags.append(
                TripBag(
                    name: imported.name,
                    items: imported.items.map {
                        TripItem(name: $0.name, symbol: symbolForItem(named: $0.name))
                    }
                )
            )
            friendCode = ""
            friendPreview = nil
            statusMessage = "\(imported.name) imported and added to this trip"
            await loadAvailableLoadouts()
            notifySuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func normalizedFriendCode() -> String {
        friendCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private func clearMessages() {
        statusMessage = nil
        errorMessage = nil
    }

    private func messageRow(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous).fill(Color.dpSurface))
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
        if lower.contains("tooth") { return "mouth.fill" }
        if lower.contains("cloth") || lower.contains("shirt") { return "tshirt.fill" }
        if lower.contains("camera") { return "camera.fill" }
        if lower.contains("passport") { return "doc.text.fill" }
        return "checklist"
    }

    private func notifyTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func notifySuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

private struct TripShareCodePreview: Decodable {
    let code: String
    let loadout: TripSharingLoadoutDTO
}

private struct TripSharingLoadoutDTO: Decodable {
    let id: UUID
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?
    let items: [TripSharingItemDTO]
}

private struct TripSharingItemDTO: Decodable {
    let id: UUID
    let name: String
    let isRecurring: Bool
    let order: Int
}

private struct TripEmptyBody: Encodable {}
