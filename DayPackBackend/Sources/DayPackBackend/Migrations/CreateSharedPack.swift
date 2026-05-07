
import Fluent

struct CreateSharedPack: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("shared_packs")
            .id()
            .field("loadout_id", .uuid, .required, .references("loadouts", "id", onDelete: .cascade))
            .field("shared_by_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("shared_with_user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("shared_packs").delete()
    }
}
