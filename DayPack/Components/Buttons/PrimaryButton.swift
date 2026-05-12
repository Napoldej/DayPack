import SwiftUI

struct PrimaryButton: View {
    enum Size {
        case sm, md, lg
        var height: CGFloat {
            switch self {
            case .sm: return 36
            case .md: return 48
            case .lg: return 52
            }
        }
        var radius: CGFloat {
            DPRadius.full
        }
        var fontSize: CGFloat {
            self == .sm ? 14 : 16
        }
    }

    let title: String
    var icon: String? = nil
    var size: Size = .lg
    var isFullWidth: Bool = true
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: { if !isLoading && !isDisabled { action() } }) {
            ZStack {
                HStack(spacing: 8) {
                    if let icon, !isLoading {
                        Image(systemName: icon)
                            .font(.system(size: size.fontSize - 1, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: size.fontSize, weight: .semibold))
                        .opacity(isLoading ? 0 : 1)
                }
                if isLoading {
                    ProgressView().tint(.white)
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, isFullWidth ? 0 : 22)
            .foregroundStyle(isDisabled ? Color.dpInk3 : Color.dpBg)
            .background(
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .fill(isDisabled ? Color.dpInk4.opacity(0.35) : Color.dpInk)
            )
            .overlay(
                RoundedRectangle(cornerRadius: size.radius, style: .continuous)
                    .stroke(isDisabled ? Color.dpDivider : Color.dpInk, lineWidth: 1)
            )
            .dpShadow(isDisabled ? .soft : .brand)
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isDisabled || isLoading)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview("PrimaryButton") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Start Walk-Out Check", action: {})
        PrimaryButton(title: "Confirm", icon: "checkmark", size: .md, action: {})
        HStack(spacing: 8) {
            PrimaryButton(title: "Save", size: .sm, isFullWidth: false, action: {})
            PrimaryButton(title: "Loading", size: .sm, isFullWidth: false, isLoading: true, action: {})
            PrimaryButton(title: "Off",  size: .sm, isFullWidth: false, isDisabled: true, action: {})
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
