import SwiftUI

struct OnboardingWelcomeView: View {
    var onGetStarted: () -> Void
    var onLogin: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "backpack")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.dpOrange)
                    .frame(width: 36, height: 36)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.dpInk)
                    )
                Text("DayPack")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Color.dpInk)
                Spacer()
            }

            Spacer()

            VStack(alignment: .leading, spacing: DPSpacing.lg) {
                Text("Never forget · Anything")
                    .dpEyebrow()
                Text("Pack like\nyou mean it.")
                    .font(.system(size: 62, weight: .black, design: .serif))
                    .italic()
                    .lineSpacing(-8)
                    .foregroundStyle(Color.dpInk)
                Text("A daily-loadout checklist that nudges you the moment you walk out the door.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.dpInk2)
                    .lineSpacing(4)

                ZStack(alignment: .topLeading) {
                    stackCard(title: "Friday", count: "2 items", background: Color.dpSurfaceAlt, foreground: Color.dpInk)
                        .offset(x: 28, y: 36)
                    stackCard(title: "Gym", count: "4 items", background: Color.dpInk, foreground: Color.dpBg)
                        .offset(x: 14, y: 18)
                    stackCard(title: "School Day", count: "6 items", background: Color.dpOrange, foreground: Color.dpInk)
                }
                .frame(height: 126)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            VStack(spacing: 0) {
                PrimaryButton(title: "Create account", icon: "arrow.right", action: onGetStarted)
                TextButton(title: "Have an account? Log in", tone: .muted, action: onLogin)
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.dpBg.ignoresSafeArea())
    }

    private func stackCard(title: String, count: String, background: Color, foreground: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                Text(count)
                    .font(.system(size: 10, weight: .bold))
                    .textCase(.uppercase)
                    .opacity(0.72)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .black))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(background)
                .shadow(color: Color.dpInk.opacity(0.12), radius: 14, x: 0, y: 8)
        )
    }
}

#Preview {
    OnboardingWelcomeView(onGetStarted: {}, onLogin: {})
}
