import SwiftUI

struct LoginView: View {
    @Environment(\.authSession) private var session

    @State private var email: String = ""
    @State private var password: String = ""

    var onBack: () -> Void = {}
    var onSwitchToRegister: () -> Void = {}

    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            backChevron
                .padding(.horizontal, 22)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: DPSpacing.lg) {
                    hero
                        .padding(.top, DPSpacing.xl)

                    VStack(spacing: DPSpacing.md) {
                        CustomTextField(
                            label: "Email",
                            text: $email,
                            placeholder: "you@example.com",
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never,
                            disableAutocorrection: true
                        )
                        CustomTextField(
                            label: "Password",
                            text: $password,
                            placeholder: "••••••••",
                            isSecure: true,
                            textContentType: .password
                        )
                    }
                    .padding(.top, DPSpacing.md)

                    if let error = session.lastError {
                        errorBanner(error)
                    }

                    PrimaryButton(
                        title: "Log in",
                        isLoading: session.isAuthenticating,
                        isDisabled: !isFormValid
                    ) {
                        Task { await session.login(email: email, password: password) }
                    }
                    .padding(.top, DPSpacing.xs)

                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.dpInk3)
                        Button(action: onSwitchToRegister) {
                            Text("Create one")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.dpOrange)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, DPSpacing.sm)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, DPSpacing.xxl)
            }
        }
        .background(Color.dpBg.ignoresSafeArea())
    }

    private var backChevron: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.dpInk2)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color.dpBgGrouped))
            }
            .buttonStyle(.plain)
            Spacer()
        }
    }

    private var hero: some View {
        VStack(spacing: DPSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.dpSurface)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.dpOrangeSoft, lineWidth: 1.5)
                    )
                Image(systemName: "backpack.fill")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(Color.dpOrange)
            }
            .shadow(color: Color.dpOrange.opacity(0.20), radius: 16, x: 0, y: 12)

            VStack(spacing: 6) {
                Text("Welcome back").dpTitle1()
                Text("Log in to keep your loadouts in sync.")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.dpInk3)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.dpRed)
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.dpRed)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: DPRadius.md, style: .continuous)
                .fill(Color.dpRedSoft)
        )
    }
}

#Preview {
    LoginView()
}
