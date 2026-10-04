import UIKit
import UserNotifications

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Set before launch finishes, so actions that launched the app are delivered.
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationScheduler().registerCategories()
        return true
    }
}
