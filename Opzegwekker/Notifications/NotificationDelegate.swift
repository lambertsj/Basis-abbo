import Foundation
import UserNotifications

/// Handles taps and actions on notifications, also when the app runs in the background.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        let action = response.actionIdentifier
        let category = content.categoryIdentifier
        let itemID = (content.userInfo[NotificationIdentifiers.itemIDKey] as? String).flatMap(UUID.init(uuidString:))

        Task { @MainActor in
            AppEnvironment.shared.model.handleNotificationResponse(action: action, category: category, itemID: itemID)
            completionHandler()
        }
    }
}
