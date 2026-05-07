import Fluent
import Vapor

final class CheckSession: Model, Content, @unchecked Sendable {
    static let schema = "check_sessions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "loadout_id")
    var loadout: Loadout
    
    @Field(key: "started_at")
    var startedAt: Date
    
    @OptionalField(key: "completed_at")
    var completedAt: Date?
    
    @Children(for: \.$checkSession)
    var checkItems: [CheckItem]
    
    init() {}
    
    init(id: UUID? = nil, loadoutID: UUID, startedAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.$loadout.id = loadoutID
        self.startedAt = startedAt
        self.completedAt = completedAt
    }
}
