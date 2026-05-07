import Vapor
import Foundation

struct TomorrowSuggestionResponseDTO: Content {
    let temporaryLoadouts: [LoadoutResponseDTO]     // ← array now
    let scheduledLoadouts: [LoadoutResponseDTO]     // ← array now
}
