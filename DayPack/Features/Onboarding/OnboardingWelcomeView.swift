import SwiftUI

struct OnboardingWelcomeView: View {
    var onGetStarted: () -> Void
    var onLogin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.dpOrange.opacity(0.18), Color.dpOrange.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 110
                        )
                    )
                    .frame(width: 220, height: 220)

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color.dpSurface)
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.dpOrangeSoft, lineWidth: 1.5)
                    )
                    .overlay(
                        Image(systemName: "backpack.fill")
                            .font(.system(size: 56, weight: .regular))
                            .foregroundStyle(Color.dpOrange)
                    )
                    .shadow(color: Color.dpOrange.opacity(0.20), radius: 20, x: 0, y: 16)
            }
            .padding(.bottom, DPSpacing.xl)

            VStack(spacing: DPSpacing.md) {
                Text("Never Forget\nAgain")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .tracking(-1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(-2)
                Text("Your smart daily-loadout companion. Pack with confidence, leave with peace of mind.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.dpInk3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DPSpacing.lg)
            }

            Spacer()

            VStack(spacing: 0) {
                PrimaryButton(title: "Get Started", action: onGetStarted)
                TextButton(title: "I already have an account", tone: .muted, action: onLogin)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBg.ignoresSafeArea())
    }
}

#Preview {
    OnboardingWelcomeView(onGetStarted: {}, onLogin: {})
}
