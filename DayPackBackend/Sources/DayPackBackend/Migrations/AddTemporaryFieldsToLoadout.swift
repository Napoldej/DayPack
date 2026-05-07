
import Fluent

struct AddTemporaryFieldsToLoadout: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("loadouts")
            .field("is_temporary", .bool, .required, .sql(.default(false)))
            .field("expires_at", .datetime)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("loadouts")
            .deleteField("is_temporary")
            .deleteField("expires_at")
            .update()
    }
}
