// Loadout.swift
import Fluent
import Vapor

final class Loadout: Model, Content,@unchecked Sendable  {
    static let schema = "loadouts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "day_type")
    var dayType: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    init(id: UUID? = nil, name: String, dayType: String, userID: User.IDValue) {
        self.id = id
        self.name = name
        self.dayType = dayType
        self.$user.id = userID
    }
}
