import Foundation
import OSLog
import UserNotifications

/// Identifiers shared by the scheduler and the delegate.
enum NotificationIdentifiers {
    static let decisionCategory = PlannedNotification.Category.decision.rawValue
    static let bundleCategory = PlannedNotification.Category.bundle.rawValue
    static let cancelAction = "CANCEL"
    static let keepAction = "KEEP"
    static let snoozeAction = "SNOOZE"
    static let itemIDKey = "itemID"
    static let itemIDsKey = "itemIDs"
}

/// Turns the domain's planned notifications into `UNNotificationRequest`s.
struct NotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "Opzegwekker", category: "notifications")

    func registerCategories() {
        let cancel = UNNotificationAction(identifier: NotificationIdentifiers.cancelAction, title: "Opzeggen", options: [.foreground])
        let keep = UNNotificationAction(identifier: NotificationIdentifiers.keepAction, title: "Houden", options: [])
        let snooze = UNNotificationAction(identifier: NotificationIdentifiers.snoozeAction, title: "Morgen opnieuw", options: [])
        let decision = UNNotificationCategory(
            identifier: NotificationIdentifiers.decisionCategory,
            actions: [cancel, keep, snooze],
            intentIdentifiers: [],
            options: []
        )
        let bundle = UNNotificationCategory(
            identifier: NotificationIdentifiers.bundleCategory,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([decision, bundle])
    }

    /// Replaces all pending requests. Rescheduling is always complete, never partial.
    func reschedule(_ planned: [PlannedNotification]) {
        center.removeAllPendingNotificationRequests()
        for notification in planned {
            center.add(Self.request(for: notification)) { [logger] error in
                if let error {
                    logger.error("Scheduling failed: \(error.localizedDescription, privacy: .public)")
                }
            }
        }
    }

    func setBadge(_ count: Int) {
        center.setBadgeCount(count) { [logger] error in
            if let error {
                logger.error("Setting the badge failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    static func request(for planned: PlannedNotification) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = planned.title
        content.body = planned.body
        content.sound = .default
        content.categoryIdentifier = planned.category.rawValue
        content.interruptionLevel = planned.isTimeSensitive ? .timeSensitive : .active
        content.threadIdentifier = "decisions"
        if let badge = planned.badge {
            content.badge = NSNumber(value: badge)
        }
        var userInfo: [String: Any] = [NotificationIdentifiers.itemIDsKey: planned.itemIDs.map(\.uuidString)]
        if let first = planned.itemIDs.first {
            userInfo[NotificationIdentifiers.itemIDKey] = first.uuidString
        }
        content.userInfo = userInfo

        // No time zone in the components: 09:00 is 09:00 wherever the user is.
        let trigger = UNCalendarNotificationTrigger(dateMatching: planned.dateComponents, repeats: false)
        return UNNotificationRequest(identifier: planned.identifier, content: content, trigger: trigger)
    }
}
