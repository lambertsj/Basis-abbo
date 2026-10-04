import Foundation

/// One reminder for one item on one day, before bundling.
struct Reminder: Hashable, Sendable {
    var itemID: UUID
    var day: CalendarDay
    var fireDate: Date
    var isTimeSensitive: Bool
    var decision: Decision
}

enum ReminderRules {
    /// Default lead days (days before the decision date) per kind of item.
    static func defaultLeads(for item: ItemData, settings: ReminderSettings) -> [Int] {
        if item.kind == .trial {
            return [settings.trialLeadDays, 0]
        }
        switch item.effectiveInterval {
        case .year: return [settings.yearLeadDays, 2]
        case .fixedEnd: return [30, 7]
        case .quarter: return [7]
        case .month, .week: return [2]
        }
    }

    /// The leads for `item`; `leadDaysOverride` replaces the first one.
    static func leads(for item: ItemData, settings: ReminderSettings) -> [Int] {
        var leads = defaultLeads(for: item, settings: settings)
        if let override = item.leadDaysOverride, !leads.isEmpty {
            leads[0] = max(0, override)
        }
        return leads
    }

    static func defaultRemindersEnabled(for item: ItemData) -> Bool {
        if item.kind == .trial { return true }
        switch item.effectiveInterval {
        case .year, .fixedEnd, .quarter: return true
        case .month, .week: return false
        }
    }

    static func remindersEnabled(for item: ItemData) -> Bool {
        item.remindersEnabledOverride ?? defaultRemindersEnabled(for: item)
    }

    /// An item "has reminders" when they are on and the current decision is not settled.
    static func hasReminders(_ item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> Bool {
        guard remindersEnabled(for: item),
              let decision = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)
        else { return false }
        return !DecisionRules.isDecided(item, decision: decision)
    }

    /// The moment `day` reaches the configured time.
    static func fireDate(on day: CalendarDay, settings: ReminderSettings, calendar: Calendar) -> Date? {
        day.date(hour: settings.hour, minute: settings.minute, calendar: calendar)
    }

    /// The configured time on `day`, or when that has passed, the next configured time
    /// after `now`. Returns nil when that falls after `latest`.
    static func slot(on day: CalendarDay, latest: CalendarDay, settings: ReminderSettings, today: CalendarDay, now: Date, calendar: Calendar) -> (CalendarDay, Date)? {
        var candidate = day
        if let date = fireDate(on: candidate, settings: settings, calendar: calendar), date > now {
            return candidate <= latest ? (candidate, date) : nil
        }
        candidate = max(day, today)
        for _ in 0..<3 {
            if let date = fireDate(on: candidate, settings: settings, calendar: calendar), date > now {
                return candidate <= latest ? (candidate, date) : nil
            }
            candidate = candidate.adding(days: 1)
        }
        return nil
    }

    /// The reminders for one item, after shifting past moments, snoozing and merging
    /// reminders that fall on the same day.
    static func reminders(for item: ItemData, settings: ReminderSettings, today: CalendarDay, now: Date, calendar: Calendar) -> [Reminder] {
        guard item.isLive, remindersEnabled(for: item),
              let decision = DecisionRules.pendingDecision(for: item, today: today, now: now, calendar: calendar)
        else { return [] }
        let decisionDate = decision.decisionDate

        var byDay: [CalendarDay: Reminder] = [:]
        func add(_ day: CalendarDay, _ date: Date) {
            let timeSensitive = day == decisionDate
            if var existing = byDay[day] {
                existing.isTimeSensitive = existing.isTimeSensitive || timeSensitive
                byDay[day] = existing
            } else {
                byDay[day] = Reminder(itemID: item.id, day: day, fireDate: date, isTimeSensitive: timeSensitive, decision: decision)
            }
        }

        for lead in leads(for: item, settings: settings) {
            let day = decisionDate.adding(days: -lead)
            if let (slotDay, date) = slot(on: day, latest: decisionDate, settings: settings, today: today, now: now, calendar: calendar) {
                add(slotDay, date)
            }
        }

        if let snooze = item.snoozeDay {
            byDay = byDay.filter { $0.key >= snooze }
            if snooze <= decisionDate,
               let (slotDay, date) = slot(on: snooze, latest: decisionDate, settings: settings, today: today, now: now, calendar: calendar) {
                add(slotDay, date)
            }
        }

        return byDay.values.sorted { $0.day < $1.day }
    }
}
