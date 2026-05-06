import SwiftUI

struct ContentView: View {
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        if hasOnboarded {
            MainTabView()
        } else {
            OnboardingWelcomeView {
                hasOnboarded = true
            }
        }
    }
}

#Preview("Main") {
    ContentView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
