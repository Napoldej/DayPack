import SwiftUI

struct TextButton: View {
    enum Tone {
        case brand, muted

        var color: Color {
            switch self {
            case .brand: return Color.dpOrange
            case .muted: return Color.dpInk3
            }
        }
    }

    let title: String
    var tone: Tone = .brand
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tone.color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview("TextButton") {
    VStack(spacing: 8) {
        TextButton(title: "I already have an account", tone: .muted, action: {})
        TextButton(title: "Forgot password?", action: {})
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.dpBg)
}
