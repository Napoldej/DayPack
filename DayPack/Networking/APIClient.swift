import Foundation
import SwiftUI

@Observable
final class APIClient {
    static let shared = APIClient()

    var baseURL: URL
    var sessionExpiredHandler: (() -> Void)?

    private let session: URLSession
    private let tokenStore: KeychainTokenStore

    init(
        session: URLSession = .shared,
        tokenStore: KeychainTokenStore = .shared,
        baseURL: URL = APIClient.defaultBaseURL
    ) {
        self.session = session
        self.tokenStore = tokenStore
        self.baseURL = baseURL
    }

    static var defaultBaseURL: URL {
        if let envOverride = ProcessInfo.processInfo.environment["DAYPACK_API_BASE_URL"],
           let url = URL(string: envOverride) {
            return url
        }
        if let storedOverride = UserDefaults.standard.string(forKey: "api.baseURL"),
           let url = URL(string: storedOverride) {
            return url
        }
        return URL(string: "http://localhost:8080")!
    }

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func get<R: Decodable>(
        _ path: String,
        query: [URLQueryItem] = [],
        requiresAuth: Bool = true
    ) async throws -> R {
        try await send(method: "GET", path: path, query: query, body: nil, requiresAuth: requiresAuth)
    }

    func post<B: Encodable, R: Decodable>(
        _ path: String,
        body: B,
        query: [URLQueryItem] = [],
        requiresAuth: Bool = true
    ) async throws -> R {
        try await send(method: "POST", path: path, query: query, body: try Self.encoder.encode(body), requiresAuth: requiresAuth)
    }

    func put<B: Encodable, R: Decodable>(
        _ path: String,
        body: B,
        requiresAuth: Bool = true
    ) async throws -> R {
        try await send(method: "PUT", path: path, query: [], body: try Self.encoder.encode(body), requiresAuth: requiresAuth)
    }

    func patch<R: Decodable>(
        _ path: String,
        requiresAuth: Bool = true
    ) async throws -> R {
        try await send(method: "PATCH", path: path, query: [], body: nil, requiresAuth: requiresAuth)
    }

    func delete(
        _ path: String,
        requiresAuth: Bool = true
    ) async throws {
        let _: EmptyResponse = try await send(method: "DELETE", path: path, query: [], body: nil, requiresAuth: requiresAuth, allowEmpty: true)
    }

    private func send<R: Decodable>(
        method: String,
        path: String,
        query: [URLQueryItem],
        body: Data?,
        requiresAuth: Bool,
        allowEmpty: Bool = false
    ) async throws -> R {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if requiresAuth, let token = tokenStore.load() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(status: -1, reason: "No HTTP response")
        }

        switch http.statusCode {
        case 200..<300:
            if allowEmpty || data.isEmpty {
                if R.self == EmptyResponse.self {
                    return EmptyResponse() as! R
                }
            }
            do {
                return try Self.decoder.decode(R.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        case 401:
            let reason = (try? Self.decoder.decode(APIErrorBody.self, from: data))?.reason
            if requiresAuth {
                tokenStore.clear()
                sessionExpiredHandler?()
                throw APIError.sessionExpired
            } else {
                throw APIError.server(status: 401, reason: reason)
            }
        case 404:
            throw APIError.notFound
        default:
            let reason = (try? Self.decoder.decode(APIErrorBody.self, from: data))?.reason
            throw APIError.server(status: http.statusCode, reason: reason)
        }
    }
}

struct EmptyResponse: Decodable {}

private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = .shared
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
