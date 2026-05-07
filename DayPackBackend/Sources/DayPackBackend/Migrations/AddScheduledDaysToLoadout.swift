import Fluent

struct AddScheduledDaysToLoadout: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("loadouts")
            .field("scheduled_days", .array(of: .int), .required, .sql(.default("{}")))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("loadouts")
            .deleteField("scheduled_days")
            .update()
    }
}
