import Foundation
import Observation

/// A cancel link the user opened, so the app can ask afterwards whether it worked.
struct PendingCancel: Codable, Equatable {
    var itemID: UUID
    var openedAt: Date
}

/// User preferences and small bits of app state, kept in the standard UserDefaults.
@Observable
final class SettingsStore {
    private enum Key {
        static let hour = "reminderHour"
        static let minute = "reminderMinute"
        static let trialLead = "trialLeadDays"
        static let yearLead = "yearLeadDays"
        static let badge = "badgeEnabled"
        static let deniedCardDismissed = "deniedCardDismissed"
        static let hasCancelledBefore = "hasCancelledBefore"
        static let pendingCancel = "pendingCancel"
    }

    @ObservationIgnored private let defaults: UserDefaults

    var reminderHour: Int { didSet { defaults.set(reminderHour, forKey: Key.hour) } }
    var reminderMinute: Int { didSet { defaults.set(reminderMinute, forKey: Key.minute) } }
    var trialLeadDays: Int { didSet { defaults.set(trialLeadDays, forKey: Key.trialLead) } }
    var yearLeadDays: Int { didSet { defaults.set(yearLeadDays, forKey: Key.yearLead) } }
    var badgeEnabled: Bool { didSet { defaults.set(badgeEnabled, forKey: Key.badge) } }
    var deniedCardDismissed: Bool { didSet { defaults.set(deniedCardDismissed, forKey: Key.deniedCardDismissed) } }
    var hasCancelledBefore: Bool { didSet { defaults.set(hasCancelledBefore, forKey: Key.hasCancelledBefore) } }
    var pendingCancel: PendingCancel? {
        didSet {
            if let pendingCancel, let data = try? JSONEncoder().encode(pendingCancel) {
                defaults.set(data, forKey: Key.pendingCancel)
            } else {
                defaults.removeObject(forKey: Key.pendingCancel)
            }
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let fallback = ReminderSettings()
        reminderHour = defaults.object(forKey: Key.hour) as? Int ?? fallback.hour
        reminderMinute = defaults.object(forKey: Key.minute) as? Int ?? fallback.minute
        trialLeadDays = defaults.object(forKey: Key.trialLead) as? Int ?? fallback.trialLeadDays
        yearLeadDays = defaults.object(forKey: Key.yearLead) as? Int ?? fallback.yearLeadDays
        badgeEnabled = defaults.object(forKey: Key.badge) as? Bool ?? fallback.badgeEnabled
        deniedCardDismissed = defaults.bool(forKey: Key.deniedCardDismissed)
        hasCancelledBefore = defaults.bool(forKey: Key.hasCancelledBefore)
        pendingCancel = defaults.data(forKey: Key.pendingCancel).flatMap { try? JSONDecoder().decode(PendingCancel.self, from: $0) }
    }

    var reminderSettings: ReminderSettings {
        ReminderSettings(
            hour: reminderHour,
            minute: reminderMinute,
            trialLeadDays: trialLeadDays,
            yearLeadDays: yearLeadDays,
            badgeEnabled: badgeEnabled
        )
    }

    /// Back to first-launch state (Alles wissen).
    func reset() {
        let fallback = ReminderSettings()
        reminderHour = fallback.hour
        reminderMinute = fallback.minute
        trialLeadDays = fallback.trialLeadDays
        yearLeadDays = fallback.yearLeadDays
        badgeEnabled = fallback.badgeEnabled
        deniedCardDismissed = false
        hasCancelledBefore = false
        pendingCancel = nil
    }
}
