import Foundation
import Observation

@Observable
final class APILoadoutService: LoadoutService {
    static let shared = APILoadoutService()

    private let api: APIClient
    private let authSession: AuthSession
    private var loadoutCache: [Loadout] = []
    private var itemCache: [UUID: [Item]] = [:]
    private var entries: [ChecklistEntry] = []
    private var sessionIDsByLoadoutID: [UUID: UUID] = [:]
    private let selectedTodayKeyPrefix = "loadouts.selectedToday."

    init(
        api: APIClient = .shared,
        authSession: AuthSession = .shared
    ) {
        self.api = api
        self.authSession = authSession
    }

    func todaysLoadout() async throws -> Loadout? {
        if let suggestion = try await tomorrowSuggestion() {
            return suggestion
        }

        let loadouts = try await allLoadouts()
        guard let userID = authSession.currentUser?.id else { return loadouts.first }
        let selectedID = UserDefaults.standard.string(forKey: selectedTodayKeyPrefix + userID.uuidString)
            .flatMap(UUID.init(uuidString:))
        return loadouts.first(where: { $0.id == selectedID }) ?? loadouts.first
    }

    func allLoadouts() async throws -> [Loadout] {
        guard let userID = authSession.currentUser?.id else { return [] }
        let dtos: [LoadoutDTO] = try await api.get(
            "/loadouts",
            query: [URLQueryItem(name: "userID", value: userID.uuidString)]
        )

        let mapped = dtos.map { $0.toModel() }
        loadoutCache = mapped
        for dto in dtos where !dto.items.isEmpty {
            itemCache[dto.id] = dto.items.map { $0.toModel() }
        }
        return mapped
    }

    private func tomorrowSuggestion() async throws -> Loadout? {
        let preview = try await loadoutsForTomorrow()
        return preview.temporary.first ?? preview.scheduled.first
    }

    func loadoutsForTomorrow() async throws -> TomorrowPreview {
        guard let userID = authSession.currentUser?.id else {
            return TomorrowPreview(scheduled: [], temporary: [])
        }
        let dto: TomorrowSuggestionDTO = try await api.get(
            "/loadouts/tomorrow",
            query: [URLQueryItem(name: "userID", value: userID.uuidString)]
        )

        let scheduled = dto.scheduledLoadouts.map { loadoutDTO -> Loadout in
            var loadout = loadoutDTO.toModel()
            loadout.isSuggestedForTomorrow = true
            if !loadoutDTO.items.isEmpty {
                itemCache[loadoutDTO.id] = loadoutDTO.items.map { $0.toModel() }
            }
            return loadout
        }
        let temporary = dto.temporaryLoadouts.map { loadoutDTO -> Loadout in
            var loadout = loadoutDTO.toModel()
            loadout.isSuggestedForTomorrow = true
            if !loadoutDTO.items.isEmpty {
                itemCache[loadoutDTO.id] = loadoutDTO.items.map { $0.toModel() }
            }
            return loadout
        }
        return TomorrowPreview(scheduled: scheduled, temporary: temporary)
    }

    func items(in loadout: Loadout) async throws -> [Item] {
        if let cached = itemCache[loadout.id] {
            return cached
        }

        let dtos: [ItemDTO] = try await api.get(
            "/items",
            query: [URLQueryItem(name: "loadoutID", value: loadout.id.uuidString)]
        )
        let mapped = dtos.map { $0.toModel() }
        itemCache[loadout.id] = mapped
        return mapped
    }

    func entries(for loadout: Loadout) async throws -> [ChecklistEntry] {
        let items = try await items(in: loadout)

        let sessionID = try await checkSessionID(for: loadout)
        var checkItems: [CheckItemDTO] = try await api.get(
            "/check-items",
            query: [URLQueryItem(name: "sessionID", value: sessionID.uuidString)]
        )

        if checkItems.isEmpty {
            for item in items {
                let created: CheckItemDTO = try await api.post(
                    "/check-items",
                    body: CheckItemCreateBody(itemID: item.id),
                    query: [URLQueryItem(name: "sessionID", value: sessionID.uuidString)]
                )
                checkItems.append(created)
            }
        }

        let mapped = checkItems.map { ChecklistEntry(id: $0.id, itemID: $0.itemID, isPacked: $0.isChecked) }
        entries.removeAll { entry in items.contains(where: { $0.id == entry.itemID }) }
        entries.append(contentsOf: mapped)
        return mapped
    }

    func togglePacked(entryID: UUID) async throws {
        let dto: CheckItemDTO = try await api.patch("/check-items/\(entryID.uuidString)/toggle")
        if let index = entries.firstIndex(where: { $0.id == entryID }) {
            entries[index].isPacked = dto.isChecked
        }
    }

    func completeCheck(for loadout: Loadout) async throws {
        let sessionID = try await checkSessionID(for: loadout)
        let _: CheckSessionDTO = try await api.patch("/check-sessions/\(sessionID.uuidString)/complete")
        sessionIDsByLoadoutID[loadout.id] = nil
        entries.removeAll { loadout.itemIDs.contains($0.itemID) }
        if loadout.isTemporary {
            itemCache[loadout.id] = nil
            loadoutCache.removeAll { $0.id == loadout.id }
        }
    }

    @discardableResult
    func createLoadout(
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        items: [Item],
        isTemporary: Bool = false,
        alertTime: String? = nil,
        returnAlertTime: String? = nil
    ) async throws -> Loadout {
        guard let userID = authSession.currentUser?.id else {
            throw APIError.sessionExpired
        }

        let created: LoadoutDTO = try await api.post(
            "/loadouts",
            body: LoadoutCreateBody(
                name: name,
                icon: symbol,
                isShared: false,
                scheduledDays: isTemporary ? [] : Self.scheduledDays(from: schedule),
                isTemporary: isTemporary,
                expiresAt: nil,
                alertTime: alertTime,
                returnAlertTime: returnAlertTime
            ),
            query: [URLQueryItem(name: "userID", value: userID.uuidString)]
        )

        var createdItems: [Item] = []
        for (index, item) in items.enumerated() {
            let dto: ItemDTO = try await api.post(
                "/items",
                body: ItemCreateBody(
                    name: item.name,
                    isRecurring: item.tag != "Optional",
                    order: index + 1
                ),
                query: [URLQueryItem(name: "loadoutID", value: created.id.uuidString)]
            )
            createdItems.append(dto.toModel(symbol: item.symbol, tint: item.tint, priority: item.priority, tag: item.tag))
        }

        let loadout = created.toModel(itemIDs: createdItems.map(\.id), fallbackSymbol: symbol, fallbackTint: tint, fallbackSchedule: schedule)
        itemCache[loadout.id] = createdItems
        entries.append(contentsOf: createdItems.map { ChecklistEntry(itemID: $0.id) })
        loadoutCache.insert(loadout, at: 0)
        try await setTodaysLoadout(id: loadout.id)
        return loadout
    }

    func deleteLoadout(id: UUID) async throws {
        try await api.delete("/loadouts/\(id.uuidString)")
        loadoutCache.removeAll { $0.id == id }
        itemCache[id] = nil
        sessionIDsByLoadoutID[id] = nil
    }

    func updateLoadout(
        _ loadout: Loadout,
        name: String,
        symbol: String,
        tint: ItemTint,
        schedule: String,
        isTemporary: Bool,
        alertTime: String?,
        returnAlertTime: String?
    ) async throws -> Loadout {
        let dto: LoadoutDTO = try await api.put(
            "/loadouts/\(loadout.id.uuidString)",
            body: LoadoutUpdateBody(
                name: name,
                icon: symbol,
                isShared: false,
                scheduledDays: isTemporary ? [] : Self.scheduledDays(from: schedule),
                isTemporary: isTemporary,
                expiresAt: nil,
                alertTime: alertTime,
                returnAlertTime: returnAlertTime
            )
        )
        let updated = dto.toModel(
            itemIDs: loadout.itemIDs,
            fallbackSymbol: symbol,
            fallbackTint: tint,
            fallbackSchedule: isTemporary ? "Temporary" : schedule
        )
        if let index = loadoutCache.firstIndex(where: { $0.id == updated.id }) {
            loadoutCache[index] = updated
        }
        return updated
    }

    func addItem(to loadout: Loadout, item: Item) async throws -> Item {
        let order = (itemCache[loadout.id]?.count ?? loadout.itemIDs.count) + 1
        let dto: ItemDTO = try await api.post(
            "/items",
            body: ItemCreateBody(name: item.name, isRecurring: item.tag != "Optional", order: order),
            query: [URLQueryItem(name: "loadoutID", value: loadout.id.uuidString)]
        )
        let created = dto.toModel(symbol: item.symbol, tint: item.tint, priority: item.priority, tag: item.tag)
        itemCache[loadout.id, default: []].append(created)
        return created
    }

    func updateItem(_ item: Item) async throws -> Item {
        let dto: ItemDTO = try await api.put(
            "/items/\(item.id.uuidString)",
            body: ItemUpdateBody(name: item.name, isRecurring: item.tag != "Optional", order: nil)
        )
        let updated = dto.toModel(symbol: item.symbol, tint: item.tint, priority: item.priority, tag: item.tag)
        for key in itemCache.keys {
            if let index = itemCache[key]?.firstIndex(where: { $0.id == item.id }) {
                itemCache[key]?[index] = updated
            }
        }
        return updated
    }

    func deleteItem(id: UUID, from loadout: Loadout) async throws {
        try await api.delete("/items/\(id.uuidString)")
        itemCache[loadout.id]?.removeAll { $0.id == id }
        entries.removeAll { $0.itemID == id }
    }

    func setTodaysLoadout(id: UUID) async throws {
        guard let userID = authSession.currentUser?.id else { return }
        UserDefaults.standard.set(id.uuidString, forKey: selectedTodayKeyPrefix + userID.uuidString)
    }

    func recentDayStats(days: Int) async throws -> [DayStat] {
        []
    }

    func currentStreak() async throws -> Int {
        0
    }

    private static func scheduledDays(from schedule: String) -> [Int] {
        let lower = schedule.lowercased()
        var days: [Int] = []
        let pairs: [(String, Int)] = [
            ("sun", 1), ("mon", 2), ("tue", 3), ("wed", 4),
            ("thu", 5), ("fri", 6), ("sat", 7),
        ]
        for (token, day) in pairs where lower.contains(token) {
            days.append(day)
        }
        return days
    }

    private func checkSessionID(for loadout: Loadout) async throws -> UUID {
        if let sessionID = sessionIDsByLoadoutID[loadout.id] {
            return sessionID
        }

        let created: CheckSessionDTO = try await api.post(
            "/check-sessions",
            body: CheckSessionCreateBody(loadoutID: loadout.id)
        )
        sessionIDsByLoadoutID[loadout.id] = created.id
        return created.id
    }
}

private struct CheckSessionDTO: Decodable {
    let id: UUID
    let loadoutID: UUID
    let startedAt: Date
    let completedAt: Date?
    let checkItems: [CheckItemDTO]
}

private struct CheckItemDTO: Decodable {
    let id: UUID
    let itemID: UUID
    let isChecked: Bool
}

private struct CheckSessionCreateBody: Encodable {
    let loadoutID: UUID
}

private struct CheckItemCreateBody: Encodable {
    let itemID: UUID
}

private struct LoadoutDTO: Decodable {
    let id: UUID
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?
    let items: [ItemDTO]

    func toModel(
        itemIDs: [UUID]? = nil,
        fallbackSymbol: String = "backpack.fill",
        fallbackTint: ItemTint = .orange,
        fallbackSchedule: String? = nil
    ) -> Loadout {
        Loadout(
            id: id,
            name: name,
            symbol: icon ?? fallbackSymbol,
            tint: fallbackTint,
            schedule: fallbackSchedule ?? Self.scheduleText(from: scheduledDays, isTemporary: isTemporary),
            itemIDs: itemIDs ?? items.map(\.id),
            scheduledDays: scheduledDays,
            isTemporary: isTemporary,
            expiresAt: expiresAt,
            alertTime: alertTime,
            returnAlertTime: returnAlertTime
        )
    }

    private static func scheduleText(from days: [Int], isTemporary: Bool) -> String {
        if isTemporary { return "Temporary" }
        guard !days.isEmpty else { return "Manual" }
        let names = [
            1: "Sun", 2: "Mon", 3: "Tue", 4: "Wed",
            5: "Thu", 6: "Fri", 7: "Sat",
        ]
        return days.compactMap { names[$0] }.joined(separator: " · ")
    }
}

private struct TomorrowSuggestionDTO: Decodable {
    let scheduledLoadouts: [LoadoutDTO]
    let temporaryLoadouts: [LoadoutDTO]
}

private struct ItemDTO: Decodable {
    let id: UUID
    let name: String
    let isRecurring: Bool
    let order: Int

    func toModel(
        symbol: String? = nil,
        tint: ItemTint? = nil,
        priority: Priority? = nil,
        tag: String? = nil
    ) -> Item {
        Item(
            id: id,
            name: name,
            symbol: symbol ?? Self.symbol(for: name),
            tint: tint ?? (isRecurring ? .orange : .blue),
            priority: priority ?? (isRecurring ? .high : .normal),
            tag: tag ?? (isRecurring ? "Always" : "Optional")
        )
    }

    private static func symbol(for name: String) -> String {
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

private struct LoadoutCreateBody: Encodable {
    let name: String
    let icon: String?
    let isShared: Bool
    let scheduledDays: [Int]
    let isTemporary: Bool
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?
}

private struct LoadoutUpdateBody: Encodable {
    let name: String?
    let icon: String?
    let isShared: Bool?
    let scheduledDays: [Int]?
    let isTemporary: Bool?
    let expiresAt: Date?
    let alertTime: String?
    let returnAlertTime: String?
}

private struct ItemCreateBody: Encodable {
    let name: String
    let isRecurring: Bool
    let order: Int
}

private struct ItemUpdateBody: Encodable {
    let name: String?
    let isRecurring: Bool?
    let order: Int?
}
