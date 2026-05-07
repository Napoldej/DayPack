import Fluent

struct CreateItem: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("items")
            .id()
            .field("name", .string, .required)
            .field("is_recurring", .bool, .required, .custom("DEFAULT false"))
            .field("order", .int, .required, .custom("DEFAULT 0"))
            .field("loadout_id", .uuid, .required, .references("loadouts", "id", onDelete: .cascade))
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("items").delete()
    }
}
