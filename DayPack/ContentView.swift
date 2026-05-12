import SwiftUI

struct ContentView: View {
    @Environment(\.authSession) private var session
    @AppStorage("hasCompletedSetup") private var hasCompletedSetup = false
    @AppStorage("setupRevision") private var setupRevision = 0

    var body: some View {
        Group {
            if session.isLoggedIn {
                if hasCompletedSetupForCurrentUser {
                    MainTabView()
                } else {
                    OnboardingSetupView()
                }
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.isLoggedIn)
        .animation(.easeInOut(duration: 0.25), value: setupRevision)
    }

    private var hasCompletedSetupForCurrentUser: Bool {
        guard let userID = session.currentUser?.id else { return hasCompletedSetup }
        return UserDefaults.standard.bool(forKey: "hasCompletedSetup.\(userID.uuidString)")
    }
}

private struct AuthFlowView: View {
    enum Screen { case welcome, login, register }
    @State private var screen: Screen = .welcome

    var body: some View {
        ZStack {
            switch screen {
            case .welcome:
                OnboardingWelcomeView(
                    onGetStarted: { screen = .register },
                    onLogin: { screen = .login }
                )
                .transition(.opacity)
            case .login:
                LoginView(
                    onBack: { screen = .welcome },
                    onSwitchToRegister: { screen = .register }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            case .register:
                RegisterView(
                    onBack: { screen = .welcome },
                    onSwitchToLogin: { screen = .login }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: screen)
    }
}

#Preview("Main") {
    ContentView()
        .environment(\.loadoutService, MockLoadoutService.shared)
}
