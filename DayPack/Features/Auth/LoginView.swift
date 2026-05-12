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
                .padding(.top, 18)

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
                                .foregroundStyle(Color.dpInk)
                                .underline()
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
        VStack(spacing: DPSpacing.lg) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome back")
                    .dpEyebrow()
                Text("Log in.")
                    .font(.system(size: 48, weight: .bold, design: .serif))
                    .italic()
                    .foregroundStyle(Color.dpInk)
                Text("Your loadouts and check history will sync as soon as you're in.")
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundStyle(Color.dpInk2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
