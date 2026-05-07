import Fluent
import Vapor

final class CheckItem: Model, Content, @unchecked Sendable {
    static let schema = "check_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "check_session_id")
    var checkSession: CheckSession
    
    @Parent(key: "item_id")
    var item: Item
    
    @Field(key: "is_checked")
    var isChecked: Bool
    
    init() {}
    
    init(id: UUID? = nil, checkSessionID: UUID, itemID: UUID, isChecked: Bool = false) {
        self.id = id
        self.$checkSession.id = checkSessionID
        self.$item.id = itemID
        self.isChecked = isChecked
    }
}
