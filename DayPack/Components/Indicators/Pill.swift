import SwiftUI

struct Pill: View {
    enum Style {
        case neutral, brand, warn, success, info

        var background: Color {
            switch self {
            case .neutral: return Color.dpSurfaceAlt
            case .brand:   return Color.dpOrange
            case .warn:    return Color.dpRedSoft
            case .success: return Color.dpGreenSoft
            case .info:    return Color.dpAmberSoft
            }
        }

        var foreground: Color {
            switch self {
            case .neutral: return Color.dpInk2
            case .brand:   return Color.dpInk
            case .warn:    return Color.dpRed
            case .success: return Color.dpGreen
            case .info:    return Color.dpAmber
            }
        }
    }

    let text: String
    var icon: String? = nil
    var style: Style = .neutral

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon).font(.system(size: 10, weight: .bold))
            }
            Text(text)
                .font(.system(size: 11, weight: .semibold))
                .textCase(.uppercase)
        }
        .padding(.horizontal, 8)
        .frame(height: 22)
        .foregroundStyle(style.foreground)
        .background(Capsule().fill(style.background))
    }
}

#Preview("Pill") {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            Pill(text: "Always",       style: .neutral)
            Pill(text: "Optional",     style: .neutral)
            Pill(text: "Don't forget", style: .warn)
        }
        HStack(spacing: 8) {
            Pill(text: "School Day",   style: .brand)
            Pill(text: "Packed",       icon: "checkmark", style: .success)
            Pill(text: "Low battery",  icon: "bolt.fill", style: .info)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
