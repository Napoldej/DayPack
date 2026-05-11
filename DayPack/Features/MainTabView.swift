import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.dpSurface)
        appearance.shadowColor = UIColor(Color.dpDivider)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            LoadoutsView()
                .tabItem {
                    Label("Loadouts", systemImage: "backpack.fill")
                }
                .tag(1)

            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "tray.full.fill")
                }
                .tag(2)

            TripPlannerView()
                .tabItem {
                    Label("Trips", systemImage: "suitcase.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(Color.dpOrange)
        .onReceive(NotificationCenter.default.publisher(for: .dayPackOpenWalkOut)) { _ in
            selectedTab = 0
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
