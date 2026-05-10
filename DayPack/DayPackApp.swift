import SwiftUI

@main
struct DayPackApp: App {
    @UIApplicationDelegateAdaptor(AppNotificationDelegate.self) private var appDelegate
    @State private var apiLoadoutService = APILoadoutService.shared
    @State private var apiClient = APIClient.shared
    @State private var authSession = AuthSession.shared
    @State private var inventoryStore = InventoryStore.shared
    private let homeLocationService = HomeLocationService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.loadoutService, apiLoadoutService)
                .environment(\.apiClient, apiClient)
                .environment(\.authSession, authSession)
                .environment(\.inventoryStore, inventoryStore)
                .environment(\.homeLocationService, homeLocationService)
                .tint(Color.dpOrange)
        }
    }
}
