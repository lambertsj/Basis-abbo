import Foundation

/// A notification the scheduler should request, independent of UserNotifications.
struct PlannedNotification: Hashable, Sendable {
    enum Category: String, Sendable {
        case decision = "DECISION"
        case bundle = "DECISION_BUNDLE"
    }

    /// `item-<uuid>-<yyyy-MM-dd>` or `day-<yyyy-MM-dd>`.
    var identifier: String
    var day: CalendarDay
    var hour: Int
    var minute: Int
    /// The moment it fires in the calendar's time zone; used for ordering.
    var fireDate: Date
    var title: String
    var body: String
    var category: Category
    var isTimeSensitive: Bool
    /// Number of items in Nu beslissen on that day; nil when the badge is off.
    var badge: Int?
    /// The single item, or all items in a bundle.
    var itemIDs: [UUID]

    /// Components for a non-repeating calendar trigger, in the current time zone.
    var dateComponents: DateComponents {
        day.dateComponents(hour: hour, minute: minute)
    }
}

enum NotificationPlanner {
    /// iOS allows 64 pending requests; stay well below.
    static let limit = 50

    /// Plans all notifications for `items`: per-item reminders, bundled per day, the
    /// earliest `limit` of them.
    /// - Parameter defaultIntervals: catalog `defaultInterval` per catalog id, used to
    ///   look ahead at transitions when computing the badge for future days.
    static func plan(
        items: [ItemData],
        settings: ReminderSettings,
        defaultIntervals: [String: BillingInterval] = [:],
        limit: Int = NotificationPlanner.limit,
        today: CalendarDay,
        now: Date,
        calendar: Calendar
    ) -> [PlannedNotification] {
        let byID = Dictionary(items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var byDay: [CalendarDay: [Reminder]] = [:]
        for item in items {
            for reminder in ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar) {
                byDay[reminder.day, default: []].append(reminder)
            }
        }

        var planned: [PlannedNotification] = []
        for (day, reminders) in byDay {
            let sorted = reminders.sorted { lhs, rhs in
                if lhs.decision.decisionDate != rhs.decision.decisionDate {
                    return lhs.decision.decisionDate < rhs.decision.decisionDate
                }
                let l = byID[lhs.itemID]?.name ?? ""
                let r = byID[rhs.itemID]?.name ?? ""
                return l.localizedStandardCompare(r) == .orderedAscending
            }
            guard let first = sorted.first, let firstItem = byID[first.itemID] else { continue }
            let badge = settings.badgeEnabled
                ? badgeCount(on: day, items: items, defaultIntervals: defaultIntervals, now: now, calendar: calendar)
                : nil
            let timeSensitive = sorted.contains { $0.isTimeSensitive }

            if sorted.count == 1 {
                let texts = singleTexts(item: firstItem, reminder: first)
                planned.append(PlannedNotification(
                    identifier: "item-\(firstItem.id.uuidString)-\(day.isoString)",
                    day: day,
                    hour: settings.hour,
                    minute: settings.minute,
                    fireDate: first.fireDate,
                    title: texts.title,
                    body: texts.body,
                    category: .decision,
                    isTimeSensitive: timeSensitive,
                    badge: badge,
                    itemIDs: [firstItem.id]
                ))
            } else {
                let names = sorted.compactMap { byID[$0.itemID]?.name }
                planned.append(PlannedNotification(
                    identifier: "day-\(day.isoString)",
                    day: day,
                    hour: settings.hour,
                    minute: settings.minute,
                    fireDate: first.fireDate,
                    title: "Vandaag \(sorted.count) beslissingen",
                    body: DutchFormat.nameList(names),
                    category: .bundle,
                    isTimeSensitive: timeSensitive,
                    badge: badge,
                    itemIDs: sorted.map(\.itemID)
                ))
            }
        }

        planned.sort { $0.fireDate != $1.fireDate ? $0.fireDate < $1.fireDate : $0.identifier < $1.identifier }
        return Array(planned.prefix(max(0, limit)))
    }

    /// Title and body for a notification about one item.
    static func singleTexts(item: ItemData, reminder: Reminder) -> (title: String, body: String) {
        let decision = reminder.decision
        let when = DutchFormat.relativeDay(decision.relevantDate, from: reminder.day)
        let title: String
        if item.kind == .trial {
            title = "\(item.name): proef eindigt \(when)"
        } else if item.effectiveInterval == .fixedEnd {
            title = "\(item.name): loopt af \(when)"
        } else {
            title = "\(item.name): verlengt \(when)"
        }

        var body: String
        if reminder.day == decision.decisionDate {
            body = "Laatste dag om kosteloos op te zeggen."
        } else {
            body = "Wil je stoppen? Zeg op vóór \(DutchFormat.short(decision.decisionDate, today: reminder.day))."
        }
        if item.kind == .trial, let price = item.priceCents {
            body += " Daarna \(DutchFormat.euro(cents: price)) \(DutchFormat.perInterval(item.effectiveInterval))."
        }
        return (title, body)
    }

    /// The number of items in Nu beslissen on `day`, after the transitions that will
    /// have run by then.
    static func badgeCount(on day: CalendarDay, items: [ItemData], defaultIntervals: [String: BillingInterval], now: Date, calendar: Calendar) -> Int {
        items.reduce(0) { count, original in
            var item = original
            let interval = item.catalogID.flatMap { defaultIntervals[$0] }
            Transitions.apply(to: &item, defaultInterval: interval, today: day, now: now, calendar: calendar)
            return count + (OverviewRules.group(for: item, today: day, now: now, calendar: calendar) == .decideNow ? 1 : 0)
        }
    }
}
