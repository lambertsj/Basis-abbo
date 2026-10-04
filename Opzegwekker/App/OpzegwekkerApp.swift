import SwiftData
import SwiftUI

@main
struct OpzegwekkerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        Appearance.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(AppEnvironment.shared.model)
                .environment(\.locale, DutchFormat.locale)
                .tint(Color.ink)
        }
        .modelContainer(AppEnvironment.shared.container)
        .backgroundTask(.appRefresh(BackgroundRefresh.identifier)) {
            await BackgroundRefresh.run()
        }
    }
}
