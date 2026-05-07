
import Fluent

struct CreateCheckSession: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("check_sessions")
            .id()
            .field("loadout_id", .uuid, .required, .references("loadouts", "id", onDelete: .cascade))
            .field("started_at", .datetime, .required)
            .field("completed_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("check_sessions").delete()
    }
}
