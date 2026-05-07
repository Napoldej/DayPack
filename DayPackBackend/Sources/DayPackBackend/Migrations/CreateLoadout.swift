import Fluent

struct CreateLoadout: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("loadouts")
            .id()
            .field("name", .string, .required)
            .field("icon", .string)
            .field("is_shared", .bool, .required, .custom("DEFAULT false"))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("loadouts").delete()
    }
}
