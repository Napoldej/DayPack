import Fluent
import Vapor

final class SharedPack: Model, Content, @unchecked Sendable {
    static let schema = "shared_packs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "loadout_id")
    var loadout: Loadout
    
    @Parent(key: "shared_by_user_id")
    var sharedByUser: User
    
    @Parent(key: "shared_with_user_id")
    var sharedWithUser: User
    
    init() {}
    
    init(id: UUID? = nil, loadoutID: UUID, sharedByUserID: UUID, sharedWithUserID: UUID) {
        self.id = id
        self.$loadout.id = loadoutID
        self.$sharedByUser.id = sharedByUserID
        self.$sharedWithUser.id = sharedWithUserID
    }
}
