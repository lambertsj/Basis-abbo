import BackgroundTasks
import Foundation
import OSLog

/// The daily `BGAppRefreshTask`: runs the transitions and reschedules.
enum BackgroundRefresh {
    static var identifier: String {
        Bundle.main.object(forInfoDictionaryKey: "OpzegwekkerRefreshTask") as? String ?? "nl.basisapps.opzegwekker.refresh"
    }

    /// Requests the next run shortly after midnight, once per day.
    static func schedule(calendar: Calendar = .current, now: Date = Date()) {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        let startOfToday = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now.addingTimeInterval(24 * 60 * 60)
        request.earliestBeginDate = calendar.date(byAdding: .minute, value: 5, to: tomorrow) ?? tomorrow
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            Logger(subsystem: "Opzegwekker", category: "background")
                .error("Scheduling the refresh failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    @MainActor
    static func run() async {
        schedule()
        await AppEnvironment.shared.model.refresh()
    }
}
