
import Fluent

struct AddReturnAlertTimeToLoadout: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("loadouts")
            .field("return_alert_time", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("loadouts")
            .deleteField("return_alert_time")
            .update()
    }
}
