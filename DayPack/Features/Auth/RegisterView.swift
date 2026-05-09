import SwiftUI

struct RegisterView: View {
    @Environment(\.authSession) private var session

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var onBack: () -> Void = {}
    var onSwitchToLogin: () -> Void = {}

    private var isEmailValid: Bool {
        email.firstMatch(of: /.+@.+\..+/) != nil
    }

    private var isPasswordValid: Bool {
        password.count >= 8
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && isEmailValid
        && isPasswordValid
        && password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 0) {
            backChevron
                .padding(.horizontal, 22)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: DPSpacing.lg) {
                    VStack(spacing: 6) {
                        Text("Create your account").dpTitle1()
                            .multilineTextAlignment(.center)
                        Text("Start packing with confidence.")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.dpInk3)
                    }
                    .padding(.top, DPSpacing.lg)

                    VStack(spacing: DPSpacing.md) {
                        CustomTextField(
                            label: "Name",
                            text: $name,
                            placeholder: "Your name",
                            textContentType: .name,
                            autocapitalization: .words
                        )
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
                            placeholder: "Create a password",
                            isSecure: true,
                            textContentType: .newPassword,
                            hint: "At least 8 characters"
                        )
                        CustomTextField(
                            label: "Confirm Password",
                            text: $confirmPassword,
                            placeholder: "Type it again",
                            isSecure: true,
                            textContentType: .newPassword,
                            hint: confirmPassword.isEmpty || password == confirmPassword ? nil : "Passwords don't match"
                        )
                    }

                    if let error = session.lastError {
                        errorBanner(error)
                    }

                    PrimaryButton(
                        title: "Create account",
                        isLoading: session.isAuthenticating,
                        isDisabled: !isFormValid
                    ) {
                        Task {
                            await session.register(
                                name: name.trimmingCharacters(in: .whitespaces),
                                email: email,
                                password: password
                            )
                        }
                    }
                    .padding(.top, DPSpacing.xs)

                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.dpInk3)
                        Button(action: onSwitchToLogin) {
                            Text("Log in")
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
    RegisterView()
}
