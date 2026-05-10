import Foundation
import SwiftUI

@Observable
final class InventoryStore {
    static let shared = InventoryStore()

    private(set) var items: [InventoryItem] = []
    private let authSession: AuthSession

    init(authSession: AuthSession = .shared) {
        self.authSession = authSession
        load()
    }

    private var storageKey: String {
        if let id = authSession.currentUser?.id {
            return "inventory.\(id.uuidString)"
        }
        return "inventory.guest"
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data)
        else {
            items = []
            return
        }
        items = decoded
    }

    func add(_ item: InventoryItem) {
        items.insert(item, at: 0)
        persist()
    }

    func update(_ item: InventoryItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        persist()
    }

    func delete(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    func reload() {
        load()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

private struct InventoryStoreKey: EnvironmentKey {
    static let defaultValue: InventoryStore = .shared
}

extension EnvironmentValues {
    var inventoryStore: InventoryStore {
        get { self[InventoryStoreKey.self] }
        set { self[InventoryStoreKey.self] = newValue }
    }
}
