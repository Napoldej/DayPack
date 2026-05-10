import Foundation
import UserNotifications

enum NotificationScheduler {
    static let walkOutReminderKey = "walkOutReminder"

    static var walkOutRemindersEnabled: Bool {
        UserDefaults.standard.object(forKey: walkOutReminderKey) as? Bool ?? true
    }

    static func sync(loadouts: [Loadout]) async throws {
        let center = UNUserNotificationCenter.current()

        let identifiers = loadouts.flatMap { loadout in
            [
                "loadout.\(loadout.id.uuidString).departure",
                "loadout.\(loadout.id.uuidString).return",
            ]
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)

        guard walkOutRemindersEnabled else { return }

        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { return }

        for loadout in loadouts {
            if let alertTime = loadout.alertTime {
                try await schedule(
                    id: "loadout.\(loadout.id.uuidString).departure",
                    title: "Pack \(loadout.name)",
                    body: "Your departure checklist is ready.",
                    time: alertTime
                )
            }
            if let returnAlertTime = loadout.returnAlertTime {
                try await schedule(
                    id: "loadout.\(loadout.id.uuidString).return",
                    title: "Bring \(loadout.name) back",
                    body: "Run your return checklist before heading home.",
                    time: returnAlertTime
                )
            }
        }
    }

    private static func schedule(id: String, title: String, body: String, time: String) async throws {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard let hour = parts.first else { return }

        var date = DateComponents()
        date.hour = hour
        date.minute = parts.dropFirst().first ?? 0

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }
}
