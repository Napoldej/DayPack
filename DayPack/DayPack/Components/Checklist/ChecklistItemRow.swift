import SwiftUI

struct ChecklistItemRow: View {
    let item: Item
    var isPacked: Bool
    var onToggle: () -> Void

    private var rowBackground: Color {
        if item.priority == .high && !isPacked { return Color(hex: 0xFFF7F4) }
        return Color.dpSurface
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DPSpacing.md) {
                Checkbox(checked: isPacked)
                IconTile(symbol: item.symbol, tint: item.tint, size: .sm)
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .tracking(-0.2)
                        .foregroundStyle(isPacked ? Color.dpInk3 : Color.dpInk)
                        .strikethrough(isPacked, color: Color.dpInk4)
                }
                Spacer(minLength: 4)
                if let tag = item.tag {
                    Pill(text: tag,
                         style: tagStyle(tag, priority: item.priority))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 56)
            .background(
                RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                    .fill(rowBackground)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(Text(item.name))
        .accessibilityValue(Text(isPacked ? "packed" : "not packed"))
        .accessibilityAddTraits(isPacked ? .isSelected : [])
    }

    private func tagStyle(_ tag: String, priority: Priority) -> Pill.Style {
        if priority == .high { return .warn }
        switch tag {
        case "Don't forget": return .warn
        case "Always":       return .neutral
        default:             return .neutral
        }
    }
}

private struct Checkbox: View {
    let checked: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.dpInk4, lineWidth: 1.6)
                .frame(width: 26, height: 26)
                .opacity(checked ? 0 : 1)
            Circle()
                .fill(Color.dpGreen)
                .frame(width: 26, height: 26)
                .opacity(checked ? 1 : 0)
                .shadow(color: Color.dpGreen.opacity(0.33), radius: 3, x: 0, y: 2)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .animation(.spring(duration: 0.22), value: checked)
    }
}

#Preview("ChecklistItemRow") {
    let notebook    = Item(name: "Notebook",     symbol: "book.closed.fill", tint: .green,  tag: "Always")
    let waterBottle = Item(name: "Water Bottle", symbol: "drop.fill",        tint: .orange)
    let proteinShake = Item(name: "Protein Shake", symbol: "drop.halffull",  tint: .red, priority: .high, tag: "Don't forget")

    return VStack(spacing: 8) {
        ChecklistItemRow(item: notebook,    isPacked: true,  onToggle: {})
        ChecklistItemRow(item: waterBottle, isPacked: false, onToggle: {})
        ChecklistItemRow(item: proteinShake, isPacked: false, onToggle: {})
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
