import SwiftUI

struct OnboardingWelcomeView: View {
    var onGetStarted: () -> Void
    var onLogin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            DPCard(padding: 18, shadow: .card) {
                HStack(spacing: DPSpacing.md) {
                    IconTile(symbol: "backpack.fill", tint: .orange, size: .lg)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DayPack")
                            .font(.system(size: 22, weight: .black))
                            .foregroundStyle(Color.dpInk)
                        Text("Daily carry, checked")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.dpInk3)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, DPSpacing.xl)

            VStack(spacing: DPSpacing.md) {
                Text("Leave with the right things.")
                    .font(.system(size: 36, weight: .heavy))
                    .multilineTextAlignment(.center)
                Text("Plan loadouts, reuse your inventory, and run a quick check before you go.")
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
