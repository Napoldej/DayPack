import SwiftUI

struct ChecklistItemRow: View {
    let item: Item
    var isPacked: Bool
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DPSpacing.md) {
                Checkbox(checked: isPacked)
                IconTile(symbol: item.symbol, tint: item.tint, size: .sm)
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isPacked ? Color.dpInk3 : Color.dpInk)
                        .strikethrough(isPacked, color: Color.dpInk4)
                }
                Spacer(minLength: 4)
                if let tag = item.tag {
                    Pill(text: tag, style: tagStyle(tag, priority: item.priority))
                }
            }
            .padding(.horizontal, DPSpacing.base)
            .padding(.vertical, DPSpacing.md)
            .frame(minHeight: 52)
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
                .stroke(Color.dpInk4, lineWidth: 1.5)
                .frame(width: 24, height: 24)
                .opacity(checked ? 0 : 1)
            Circle()
                .fill(Color.dpInk)
                .frame(width: 24, height: 24)
                .opacity(checked ? 1 : 0)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.dpBg)
            }
        }
        .animation(.easeOut(duration: 0.15), value: checked)
    }
}

#Preview("ChecklistItemRow") {
    let notebook    = Item(name: "Notebook",     symbol: "book.closed.fill", tint: .green,  tag: "Always")
    let waterBottle = Item(name: "Water Bottle", symbol: "drop.fill",        tint: .orange)
    let proteinShake = Item(name: "Protein Shake", symbol: "drop.halffull",  tint: .red, priority: .high, tag: "Don't forget")

    return VStack(spacing: 0) {
        ChecklistItemRow(item: notebook,    isPacked: true,  onToggle: {})
        Divider().padding(.leading, 56)
        ChecklistItemRow(item: waterBottle, isPacked: false, onToggle: {})
        Divider().padding(.leading, 56)
        ChecklistItemRow(item: proteinShake, isPacked: false, onToggle: {})
    }
    .background(Color.dpSurface)
    .clipShape(RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous))
    .overlay(
        RoundedRectangle(cornerRadius: DPRadius.lg, style: .continuous)
            .stroke(Color.dpDivider, lineWidth: 1)
    )
    .dpShadow(.soft)
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
