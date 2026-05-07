import Fluent
import Vapor

protocol TomorrowSuggestionServiceProtocol: Sendable {
    func suggest(userID: UUID, on db: any Database) async throws -> TomorrowSuggestionResponseDTO
}

struct TomorrowSuggestionService: TomorrowSuggestionServiceProtocol, @unchecked Sendable {
    let repository: any LoadoutRepositoryProtocol

    func suggest(userID: UUID, on db: any Database) async throws -> TomorrowSuggestionResponseDTO {
        let loadouts = try await repository.findAll(for: userID, on: db)

        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let tomorrowWeekday = Calendar.current.component(.weekday, from: tomorrow)

        // Find ALL temporary loadouts for tomorrow
        let temporaryLoadouts = loadouts.filter {
            $0.isTemporary &&
            $0.expiresAt != nil &&
            Calendar.current.isDate($0.expiresAt!, inSameDayAs: tomorrow)
        }

        // Find ALL scheduled loadouts for tomorrow
        let scheduledLoadouts = loadouts.filter {
            !$0.isTemporary &&
            $0.scheduledDays.contains(tomorrowWeekday)
        }

        return TomorrowSuggestionResponseDTO(
            temporaryLoadouts: temporaryLoadouts.map { $0.toDTO() },
            scheduledLoadouts: scheduledLoadouts.map { $0.toDTO() }
        )
    }
}
