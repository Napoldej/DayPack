import UIKit
import UserNotifications

extension Notification.Name {
    static let dayPackOpenWalkOut = Notification.Name("dayPackOpenWalkOut")
}

final class AppNotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.notification.request.content.userInfo["dayPackAction"] as? String == "walkOut" else { return }
        await MainActor.run {
            NotificationCenter.default.post(name: .dayPackOpenWalkOut, object: nil)
        }
    }
}
