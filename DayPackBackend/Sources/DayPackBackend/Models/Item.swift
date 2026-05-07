import Fluent
import Vapor

final class Item: Model, Content, @unchecked Sendable {
    static let schema = "items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "is_recurring")
    var isRecurring: Bool
    
    @Field(key: "order")
    var order: Int
    
    @Parent(key: "loadout_id")
    var loadout: Loadout
    
    init() {}
    
    init(id: UUID? = nil, name: String, isRecurring: Bool = false, order: Int = 0, loadoutID: UUID) {
        self.id = id
        self.name = name
        self.isRecurring = isRecurring
        self.order = order
        self.$loadout.id = loadoutID
    }
}
