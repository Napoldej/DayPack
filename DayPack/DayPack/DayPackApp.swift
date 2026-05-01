import SwiftUI

@main
struct DayPackApp: App {
    @State private var loadoutService = MockLoadoutService.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.loadoutService, loadoutService)
                .tint(Color.dpOrange)
        }
    }
}
