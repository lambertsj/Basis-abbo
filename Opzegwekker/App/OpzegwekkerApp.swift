import SwiftData
import SwiftUI

@main
struct OpzegwekkerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AppEnvironment.shared.model)
                .environment(\.locale, DutchFormat.locale)
        }
        .modelContainer(AppEnvironment.shared.container)
        .backgroundTask(.appRefresh(BackgroundRefresh.identifier)) {
            await BackgroundRefresh.run()
        }
    }
}
