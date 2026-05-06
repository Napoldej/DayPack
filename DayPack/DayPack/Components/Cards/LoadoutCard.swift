import SwiftUI

struct LoadoutCard: View {
    enum Style {
        case standard, compact
    }

    let loadout: Loadout
    var itemCount: Int
    var isActive: Bool = false
    var style: Style = .standard
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            ZStack(alignment: .topTrailing) {
                content
                if isActive {
                    Text("Today")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.dpOrange))
                        .padding(12)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                    .fill(Color.dpSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                    .stroke(isActive ? Color.dpOrange : .clear, lineWidth: 1.5)
            )
            .dpShadow(.soft)
        }
        .buttonStyle(PressableButtonStyle())
    }

    @ViewBuilder
    private var content: some View {
        switch style {
        case .standard:
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .lg)
                VStack(alignment: .leading, spacing: 3) {
                    Text(loadout.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .tracking(-0.3)
                        .foregroundStyle(Color.dpInk)
                    Text("\(itemCount) items · \(loadout.schedule)")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color.dpInk3)
                }
                Spacer(minLength: 0)
            }
            .padding(DPSpacing.base)

        case .compact:
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .md)
                VStack(alignment: .leading, spacing: 2) {
                    Text(loadout.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("\(itemCount) items · \(loadout.schedule)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dpInk3)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.dpInk4)
            }
            .padding(DPSpacing.md)
        }
    }
}

#Preview("LoadoutCard") {
    let school = Loadout(name: "School Day", symbol: "book.closed.fill", tint: .orange, schedule: "Mon · Wed · Fri")
    let gym    = Loadout(name: "Gym Day",    symbol: "dumbbell.fill",    tint: .purple, schedule: "Tue · Thu · Sat")
    let travel = Loadout(name: "Travel",     symbol: "paperplane.fill",  tint: .teal,   schedule: "Manual")

    return VStack(spacing: 12) {
        LoadoutCard(loadout: school, itemCount: 8, isActive: true)
        LoadoutCard(loadout: gym,    itemCount: 6)
        LoadoutCard(loadout: travel, itemCount: 14, style: .compact)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
