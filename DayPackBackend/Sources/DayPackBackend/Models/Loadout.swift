import Fluent
import Vapor

final class Loadout: Model, Content, @unchecked Sendable {
    static let schema = "loadouts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "icon")
    var icon: String?
    
    @Field(key: "is_shared")
    var isShared: Bool
    
    @Parent(key: "user_id")
    var user: User
    
    @Children(for: \.$loadout)
    var items: [Item]
    
    init() {}
    
    init(id: UUID? = nil, name: String, icon: String? = nil, isShared: Bool = false, userID: UUID) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isShared = isShared
        self.$user.id = userID
    }
}
