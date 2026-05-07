// Models/Loadout.swift
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
    
    @Field(key: "scheduled_days")
    var scheduledDays: [Int]

    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "is_temporary")
    var isTemporary: Bool
    
    @OptionalField(key: "expires_at")
    var expiresAt: Date?

    @Children(for: \.$loadout)
    var items: [Item]
    
    @OptionalField(key: "alert_time")
    var alertTime: String?  // "07:00" — stored as HH:mm string

    init() {}

    init(id: UUID? = nil, name: String, icon: String? = nil, isShared: Bool = false, scheduledDays: [Int] = [], isTemporary: Bool = false, expiresAt: Date? = nil, alertTime: String? = nil, userID: UUID) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isShared = isShared
        self.scheduledDays = scheduledDays
        self.isTemporary = isTemporary
        self.expiresAt = expiresAt
        self.alertTime = alertTime
        self.$user.id = userID
    }
}
