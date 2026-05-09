import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case sessionExpired
    case notFound
    case server(status: Int, reason: String?)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                  return "Invalid request URL."
        case .sessionExpired:              return "Your session has expired. Please log in again."
        case .notFound:                    return "Not found."
        case .server(_, let reason):
            return reason ?? "Something went wrong. Please try again."
        case .decoding(let error):         return "Couldn't read server response: \(error.localizedDescription)"
        case .transport(let error):        return "Network error: \(error.localizedDescription)"
        }
    }
}

struct APIErrorBody: Decodable {
    let error: Bool
    let reason: String?
}
