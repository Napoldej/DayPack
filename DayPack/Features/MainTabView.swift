import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        Group {
            switch selectedTab {
            case 0: TodayView()
            case 1: LoadoutsView()
            case 2: InventoryView()
            case 3: TripPlannerView()
            case 4: SettingsView()
            default: TodayView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            V2TabBar(selectedTab: $selectedTab)
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, 2)
                .allowsHitTesting(true)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: .dayPackOpenWalkOut)) { _ in
            selectedTab = 0
        }
    }
}

private struct V2TabBar: View {
    @Binding var selectedTab: Int

    private let tabs: [(icon: String, label: String)] = [
        ("sun.max", "Today"),
        ("backpack", "Loadouts"),
        ("square.grid.2x2", "Inventory"),
        ("map", "Trips"),
        ("gearshape", "Settings"),
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedTab = index
                    }
                } label: {
                    tabLabel(for: index)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tabs[index].label)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(Color.dpInk)
                .shadow(color: Color.dpInk.opacity(0.24), radius: 14, x: 0, y: 8)
        )
    }

    @ViewBuilder
    private func tabLabel(for index: Int) -> some View {
        let isSelected = selectedTab == index
        HStack(spacing: 6) {
            Image(systemName: tabs[index].icon)
                .font(.system(size: isSelected ? 15 : 17, weight: .bold))
            if isSelected {
                Text(tabs[index].label)
                    .font(.system(size: 12, weight: .bold))
                    .lineLimit(1)
            }
        }
        .foregroundStyle(isSelected ? Color.dpInk : Color.dpBg)
        .frame(width: isSelected ? nil : 36, height: 36)
        .padding(.horizontal, isSelected ? 13 : 0)
        .background(
            Capsule()
                .fill(isSelected ? Color.dpOrange : .clear)
        )
    }
}

#Preview {
    MainTabView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
