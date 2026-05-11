import SwiftUI

struct SecondaryButton: View {
    enum Variant {
        case soft, ghost, danger

        var background: Color {
            switch self {
            case .soft:   return Color.dpSurface
            case .ghost:  return .clear
            case .danger: return Color.dpRedSoft
            }
        }

        var foreground: Color {
            switch self {
            case .soft:   return Color.dpOrangeDeep
            case .ghost:  return Color.dpInk2
            case .danger: return Color.dpRed
            }
        }
    }

    let title: String
    var icon: String? = nil
    var variant: Variant = .soft
    var size: PrimaryButton.Size = .lg
    var isFullWidth: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: size.fontSize - 1, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: size.fontSize, weight: .semibold))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, isFullWidth ? 0 : 22)
            .foregroundStyle(variant.foreground)
            .background(
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .fill(variant.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                            .stroke(variant == .ghost ? .clear : Color.dpDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview("SecondaryButton") {
    VStack(spacing: 16) {
        SecondaryButton(title: "I already have an account", variant: .soft, action: {})
        SecondaryButton(title: "Cancel", variant: .ghost, action: {})
        SecondaryButton(title: "Delete loadout", icon: "trash.fill", variant: .danger, action: {})
        HStack(spacing: 8) {
            SecondaryButton(title: "Skip", size: .sm, isFullWidth: false, action: {})
            SecondaryButton(title: "Edit", icon: "pencil", variant: .ghost, size: .sm, isFullWidth: false, action: {})
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
