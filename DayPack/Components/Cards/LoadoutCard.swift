import SwiftUI

struct LoadoutCard: View {
    enum Style {
        case standard, compact
    }

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

    let loadout: Loadout
    var itemCount: Int
    var isActive: Bool = false
    var style: Style = .standard
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            content
                .background(
                    RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                        .fill(Color.dpSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                        .stroke(isActive ? Color.dpOrange.opacity(0.7) : Color.dpDivider, lineWidth: 1)
                )
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: DPRadius.xl, style: .continuous)
                        .fill(isActive ? Color.dpOrange : Color.dpDivider)
                        .frame(width: 4)
                }
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
                VStack(alignment: .leading, spacing: 6) {
                    Text(loadout.name)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundStyle(Color.dpInk)
                    Text("\(itemCount) items · \(loadout.schedule)")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Color.dpInk3)
                    metadataChips
                }
                Spacer(minLength: 0)
            }
            .padding(DPSpacing.base)
            .padding(.leading, 4)

        case .compact:
            HStack(spacing: DPSpacing.md) {
                IconTile(symbol: loadout.symbol, tint: loadout.tint, size: .md)
                VStack(alignment: .leading, spacing: 5) {
                    Text(loadout.name)
                        .font(.system(size: 16, weight: .bold, design: .default))
                    Text("\(itemCount) items · \(loadout.schedule)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.dpInk3)
                    metadataChips
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.dpInk4)
            }
            .padding(DPSpacing.md)
            .padding(.leading, 4)
        }
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
                    .background(
                        Capsule()
                            .fill(chip.color.opacity(0.10))
                            .overlay(Capsule().stroke(chip.color.opacity(0.16), lineWidth: 1))
                    )
                }
            }
        }
    }

    private var metadata: [MetadataChip] {
        var chips: [MetadataChip] = []
        if isActive {
            chips.append(MetadataChip(symbol: "checkmark.seal.fill", text: "Today", color: Color.dpOrangeDeep))
        }
        if loadout.isSuggestedForTomorrow {
            chips.append(MetadataChip(symbol: "calendar", text: "Tomorrow", color: Color.dpOrangeDeep))
        }
        if loadout.isTemporary {
            chips.append(MetadataChip(symbol: "sparkles", text: "Temp", color: Color.dpOrangeDeep))
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
        LoadoutCard(loadout: travel, itemCount: 14, style: .compact)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
