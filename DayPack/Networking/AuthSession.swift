import Foundation
import SwiftUI

struct AuthUser: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let email: String
}

private struct AuthResponse: Decodable {
    let token: String
    let user: AuthUser
}

private struct RegisterBody: Encodable {
    let name: String
    let email: String
    let password: String
}

private struct LoginBody: Encodable {
    let email: String
    let password: String
}

@Observable
final class AuthSession {
    static let shared = AuthSession()

    private(set) var currentUser: AuthUser?
    private(set) var isAuthenticating: Bool = false
    var lastError: String?

    private let api: APIClient
    private let tokenStore: KeychainTokenStore

    var isLoggedIn: Bool { currentUser != nil }

    init(
        api: APIClient = .shared,
        tokenStore: KeychainTokenStore = .shared
    ) {
        self.api = api
        self.tokenStore = tokenStore
        loadCachedUser()
        api.sessionExpiredHandler = { [weak self] in
            Task { @MainActor in self?.logout() }
        }
    }

    func login(email: String, password: String) async {
        await perform {
            let response: AuthResponse = try await api.post(
                "/auth/login",
                body: LoginBody(email: email, password: password),
                requiresAuth: false
            )
            tokenStore.save(response.token)
            cacheUser(response.user)
            UserDefaults.standard.set(false, forKey: "hasCompletedSetup")
            UserDefaults.standard.set(false, forKey: "hasCompletedSetup.\(response.user.id.uuidString)")
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "setupRevision") + 1, forKey: "setupRevision")
            currentUser = response.user
            InventoryStore.shared.reload()
        }
    }

    func register(name: String, email: String, password: String) async {
        await perform {
            let response: AuthResponse = try await api.post(
                "/auth/register",
                body: RegisterBody(name: name, email: email, password: password),
                requiresAuth: false
            )
            tokenStore.save(response.token)
            cacheUser(response.user)
            currentUser = response.user
            InventoryStore.shared.reload()
        }
    }

    func logout() {
        tokenStore.clear()
        UserDefaults.standard.removeObject(forKey: cachedUserKey)
        currentUser = nil
        InventoryStore.shared.reload()
    }

    func updateAccount(name: String, email: String) async {
        guard let userID = currentUser?.id else { return }
        await perform {
            let user: AuthUser = try await api.put(
                "/users/\(userID.uuidString)",
                body: UserUpdateBody(name: name, email: email, password: nil)
            )
            cacheUser(user)
            currentUser = user
        }
    }

    func deleteAccount() async {
        guard let userID = currentUser?.id else { return }
        await perform {
            try await api.delete("/users/\(userID.uuidString)")
            logout()
        }
    }

    private func perform(_ work: @MainActor () async throws -> Void) async {
        isAuthenticating = true
        lastError = nil
        defer { isAuthenticating = false }
        do {
            try await work()
        } catch let error as APIError {
            lastError = error.errorDescription
        } catch {
            lastError = error.localizedDescription
        }
    }

    private let cachedUserKey = "auth.cachedUser"

    private func cacheUser(_ user: AuthUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: cachedUserKey)
        }
    }

    private func loadCachedUser() {
        guard tokenStore.load() != nil,
              let data = UserDefaults.standard.data(forKey: cachedUserKey),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data)
        else { return }
        currentUser = user
    }
}

private struct UserUpdateBody: Encodable {
    let name: String?
    let email: String?
    let password: String?
}

private struct AuthSessionKey: EnvironmentKey {
    static let defaultValue: AuthSession = .shared
}

extension EnvironmentValues {
    var authSession: AuthSession {
        get { self[AuthSessionKey.self] }
        set { self[AuthSessionKey.self] = newValue }
    }
}
