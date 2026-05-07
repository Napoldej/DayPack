
import Fluent

struct CreateCheckItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("check_items")
            .id()
            .field("check_session_id", .uuid, .required, .references("check_sessions", "id", onDelete: .cascade))
            .field("item_id", .uuid, .required, .references("items", "id", onDelete: .cascade))
            .field("is_checked", .bool, .required, .custom("DEFAULT false"))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("check_items").delete()
    }
}
