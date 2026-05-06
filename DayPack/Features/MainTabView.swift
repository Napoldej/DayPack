import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            LoadoutsView()
                .tabItem {
                    Label("Loadouts", systemImage: "backpack.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "flame.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.dpOrange)
    }
}

#Preview {
    MainTabView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
