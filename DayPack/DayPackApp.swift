import SwiftUI

@main
struct DayPackApp: App {
    @State private var loadoutService = MockLoadoutService.shared
    @State private var apiClient = APIClient.shared
    @State private var authSession = AuthSession.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.loadoutService, loadoutService)
                .environment(\.apiClient, apiClient)
                .environment(\.authSession, authSession)
                .tint(Color.dpOrange)
        }
    }
}
