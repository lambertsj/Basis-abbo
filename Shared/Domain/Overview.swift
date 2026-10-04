import Foundation

enum OverviewGroup: Int, CaseIterable, Hashable, Sendable {
    case decideNow
    case soon
    case ongoing
    case cancelled
    case stopped

    var title: String {
        switch self {
        case .decideNow: "Nu beslissen"
        case .soon: "Binnenkort"
        case .ongoing: "Loopt door"
        case .cancelled: "Opgezegd"
        case .stopped: "Gestopt"
        }
    }

    var isCollapsedByDefault: Bool {
        self == .cancelled || self == .stopped
    }
}

/// One group of the overview with its sorted items.
struct OverviewSection: Identifiable, Hashable, Sendable {
    var group: OverviewGroup
    var items: [ItemData]

    var id: OverviewGroup { group }
}

enum Urgency: Hashable, Sendable {
    case high
    case medium
    case normal

    /// Red at 2 days or less, orange at 7 or less.
    init(daysLeft: Int) {
        if daysLeft <= 2 {
            self = .high
        } else if daysLeft <= 7 {
            self = .medium
        } else {
            self = .normal
        }
    }
}

enum OverviewRules {
    static func group(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> OverviewGroup {
        switch item.status {
        case .cancelled: return .cancelled
        case .stopped: return .stopped
        case .trial, .active: break
        }
        guard ReminderRules.hasReminders(item, today: today, now: now, calendar: calendar),
              let decision = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)
        else { return .ongoing }
        if decision.decisionDate <= today.adding(days: 7) { return .decideNow }
        if decision.decisionDate <= today.adding(days: 30) { return .soon }
        return .ongoing
    }

    /// The day an item sorts on: the decision date, or `usableUntil` once cancelled or stopped.
    static func sortDay(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> CalendarDay? {
        switch item.status {
        case .cancelled, .stopped:
            return item.usableUntil
        case .trial, .active:
            return DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)?.decisionDate
        }
    }

    /// Non-empty groups in display order, each sorted by date (earliest first, missing
    /// dates last, then by name).
    static func grouped(_ items: [ItemData], today: CalendarDay, now: Date, calendar: Calendar) -> [OverviewSection] {
        var buckets: [OverviewGroup: [(ItemData, CalendarDay?)]] = [:]
        for item in items {
            let group = group(for: item, today: today, now: now, calendar: calendar)
            buckets[group, default: []].append((item, sortDay(for: item, today: today, now: now, calendar: calendar)))
        }
        return OverviewGroup.allCases.compactMap { group in
            guard let entries = buckets[group], !entries.isEmpty else { return nil }
            let sorted = entries.sorted { lhs, rhs in
                switch (lhs.1, rhs.1) {
                case let (l?, r?) where l != r: return l < r
                case (nil, _?): return false
                case (_?, nil): return true
                default: return lhs.0.name.localizedStandardCompare(rhs.0.name) == .orderedAscending
                }
            }
            return OverviewSection(group: group, items: sorted.map(\.0))
        }
    }

    /// Number of items in Nu beslissen; used for the app badge.
    static func decideNowCount(_ items: [ItemData], today: CalendarDay, now: Date, calendar: Calendar) -> Int {
        items.filter { group(for: $0, today: today, now: now, calendar: calendar) == .decideNow }.count
    }

    /// The first item in Nu beslissen or Binnenkort, for the widget.
    static func nextUp(_ items: [ItemData], today: CalendarDay, now: Date, calendar: Calendar) -> ItemData? {
        let groups = grouped(items, today: today, now: now, calendar: calendar)
        return groups.first { $0.group == .decideNow || $0.group == .soon }?.items.first
    }
}

/// Monthly cost estimate.
struct MonthlyTotal: Hashable, Sendable {
    /// Sum normalised to one month, in (fractional) cents.
    var cents: Double
    /// Items with a price that were counted.
    var pricedCount: Int
    /// All items with the requested status.
    var totalCount: Int

    var isEmpty: Bool { pricedCount == 0 }

    /// Normalised monthly cents for one price.
    static func monthlyCents(priceCents: Int, interval: BillingInterval) -> Double {
        let price = Double(priceCents)
        switch interval {
        case .week: return price * 52 / 12
        case .month, .fixedEnd: return price
        case .quarter: return price / 3
        case .year: return price / 12
        }
    }

    static func compute(_ items: [ItemData], status: Status, today: CalendarDay, now: Date, calendar: Calendar) -> MonthlyTotal {
        let matching = items.filter { $0.status == status }
        var cents = 0.0
        var priced = 0
        for item in matching {
            guard let price = item.priceCents else { continue }
            cents += monthlyCents(priceCents: price, interval: item.effectiveInterval)
            priced += 1
        }
        return MonthlyTotal(cents: cents, pricedCount: priced, totalCount: matching.count)
    }

    /// "± € 47 per maand"
    var activeText: String {
        "± \(DutchFormat.euroRounded(cents: cents)) per maand"
    }

    /// "Samen € 34 per maand minder"
    var stoppedText: String {
        "Samen \(DutchFormat.euroRounded(cents: cents)) per maand minder"
    }

    /// "Berekend op basis van 5 van 7 abonnementen."
    var explanation: String {
        let noun = totalCount == 1 ? "abonnement" : "abonnementen"
        return "Berekend op basis van \(pricedCount) van \(totalCount) \(noun)."
    }
}
