
import Fluent

struct AddAlertTimeToLoadout: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("loadouts")
            .field("alert_time", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("loadouts")
            .deleteField("alert_time")
            .update()
    }
}
