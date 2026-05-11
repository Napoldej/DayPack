import Fluent

struct CreateShareCode: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("share_codes")
            .id()
            .field("code", .string, .required)
            .field("loadout_id", .uuid, .required, .references("loadouts", "id", onDelete: .cascade))
            .field("created_by_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "code")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("share_codes").delete()
    }
}
