import SwiftUI

struct LoadoutCard: View {
    let loadout: Loadout
    var itemCount: Int
    var isActive: Bool = false
    var onTap: (() -> Void)? = nil

    private struct MetadataChip: Hashable {
        let symbol: String
        let text: String
        let color: Color

        static func == (lhs: MetadataChip, rhs: MetadataChip) -> Bool {
            lhs.symbol == rhs.symbol && lhs.text == rhs.text
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(symbol)
            hasher.combine(text)
        }
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .lg)

                VStack(alignment: .leading, spacing: 5) {
                    Text(loadout.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isActive ? Color.dpBg : Color.dpInk)

                    Text("\(itemCount) items · \(loadout.schedule)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isActive ? Color.dpInk4 : Color.dpInk3)

                    metadataChips
                }
                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isActive ? Color.dpOrange : Color.dpInk4)
            }
            .padding(DPSpacing.base)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .fill(isActive ? Color.dpInk : Color.dpSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
                    .stroke(isActive ? Color.dpInk : Color.dpDivider, lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                if isActive {
                    UnevenRoundedRectangle(
                        topLeadingRadius: DPRadius.lg,
                        bottomLeadingRadius: DPRadius.lg,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                    .fill(Color.dpOrange)
                    .frame(width: 4)
                }
            }
            .dpShadow(.soft)
        }
        .buttonStyle(PressableButtonStyle())
    }

    @ViewBuilder
    private var metadataChips: some View {
        let chips = metadata
        if !chips.isEmpty {
            HStack(spacing: 6) {
                ForEach(chips, id: \.self) { chip in
                    HStack(spacing: 4) {
                        Image(systemName: chip.symbol)
                            .font(.system(size: 9, weight: .bold))
                        Text(chip.text)
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(chip.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(chip.color.opacity(0.10)))
                }
            }
        }
    }

    private var metadata: [MetadataChip] {
        var chips: [MetadataChip] = []
        if isActive {
            chips.append(MetadataChip(symbol: "checkmark.seal.fill", text: "Active", color: Color.dpOrange))
        }
        if loadout.isSuggestedForTomorrow {
            chips.append(MetadataChip(symbol: "calendar", text: "Tomorrow", color: Color.dpAmber))
        }
        if loadout.isTemporary {
            chips.append(MetadataChip(symbol: "sparkles", text: "Temp", color: Color.dpAmber))
        }
        if let alertTime = loadout.alertTime {
            chips.append(MetadataChip(symbol: "bell.fill", text: alertTime, color: Color.dpInk3))
        }
        if let returnAlertTime = loadout.returnAlertTime {
            chips.append(MetadataChip(symbol: "arrow.uturn.backward", text: returnAlertTime, color: Color.dpInk3))
        }
        return chips
    }
}

#Preview("LoadoutCard") {
    let school = Loadout(name: "School Day", symbol: "book.closed.fill", tint: .orange, schedule: "Mon · Wed · Fri")
    let gym    = Loadout(name: "Gym Day",    symbol: "dumbbell.fill",    tint: .purple, schedule: "Tue · Thu · Sat")
    let travel = Loadout(name: "Travel",     symbol: "paperplane.fill",  tint: .teal,   schedule: "Manual")

    return VStack(spacing: 12) {
        LoadoutCard(loadout: school, itemCount: 8, isActive: true)
        LoadoutCard(loadout: gym,    itemCount: 6)
        LoadoutCard(loadout: travel, itemCount: 14)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
