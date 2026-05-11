import Fluent
import Vapor

final class ShareCode: Model, Content, @unchecked Sendable {
    static let schema = "share_codes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "code")
    var code: String

    @Parent(key: "loadout_id")
    var loadout: Loadout

    @Parent(key: "created_by_user_id")
    var createdByUser: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(id: UUID? = nil, code: String, loadoutID: UUID, createdByUserID: UUID) {
        self.id = id
        self.code = code
        self.$loadout.id = loadoutID
        self.$createdByUser.id = createdByUserID
    }
}
