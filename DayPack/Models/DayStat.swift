import Foundation

struct DayStat: Identifiable, Hashable, Codable {
    let id: UUID
    var date: Date
    var completion: Double

    init(id: UUID = UUID(), date: Date, completion: Double) {
        self.id = id
        self.date = date
        self.completion = max(0, min(1, completion))
    }
}
