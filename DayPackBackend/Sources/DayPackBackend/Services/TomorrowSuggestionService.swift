import Fluent
import Vapor

protocol TomorrowSuggestionServiceProtocol: Sendable {
    func suggest(userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO?
}

struct TomorrowSuggestionService: TomorrowSuggestionServiceProtocol, @unchecked Sendable {
    let repository: any LoadoutRepositoryProtocol

    func suggest(userID: UUID, on db: any Database) async throws -> LoadoutResponseDTO? {
        let loadouts = try await repository.findAll(for: userID, on: db)

        // Get tomorrow's weekday
        // 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowWeekday = Calendar.current.component(.weekday, from: tomorrow)

        // Find first matching profile
        let matched = loadouts.first { $0.scheduledDays.contains(tomorrowWeekday) }
        return matched?.toDTO()
    }
}
