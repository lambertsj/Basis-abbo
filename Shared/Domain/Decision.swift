import Foundation

/// The decision an item asks for: the date it matters for and the last day to cancel.
struct Decision: Hashable, Sendable {
    /// The first relevant date on or after today: trial end, next renewal or fixed end.
    var nextDate: CalendarDay
    /// The date this decision is about. Equals `nextDate`, except when it is too late
    /// for this round; then it is a later renewal.
    var relevantDate: CalendarDay
    /// `relevantDate` minus the notice period: the last day to cancel.
    var decisionDate: CalendarDay
    /// The notice period for `nextDate` has already passed.
    var isTooLateThisRound: Bool
}

enum DecisionRules {
    /// Months per step for month-based intervals.
    private static func months(for interval: BillingInterval) -> Int? {
        switch interval {
        case .month: 1
        case .quarter: 3
        case .year: 12
        case .week, .fixedEnd: nil
        }
    }

    /// Renewal number `n`, always computed from the anchor (`anchor + n × interval`),
    /// never from the previous renewal, so the 31st does not drift to the 28th.
    static func renewal(anchor: CalendarDay, interval: BillingInterval, index n: Int) -> CalendarDay {
        if let step = months(for: interval) {
            return anchor.adding(months: n * step)
        }
        if interval == .week {
            return anchor.adding(days: 7 * n)
        }
        return anchor
    }

    /// The smallest `n ≥ 0` for which the renewal falls on or after `today`.
    static func firstRenewalIndex(anchor: CalendarDay, interval: BillingInterval, onOrAfter today: CalendarDay) -> Int {
        guard anchor < today else { return 0 }
        var n: Int
        if let step = months(for: interval) {
            let monthsApart = (today.year - anchor.year) * 12 + (today.month - anchor.month)
            n = max(0, monthsApart / step - 1)
        } else if interval == .week {
            n = max(0, anchor.days(until: today) / 7 - 1)
        } else {
            return 0
        }
        while renewal(anchor: anchor, interval: interval, index: n) < today {
            n += 1
        }
        return n
    }

    static func subtractNotice(from day: CalendarDay, value: Int, unit: NoticeUnit) -> CalendarDay {
        guard value > 0 else { return day }
        switch unit {
        case .days: return day.adding(days: -value)
        case .months: return day.adding(months: -value)
        }
    }

    /// The relevant date: trial end, next renewal on or after today, or the fixed end date.
    static func relevantDate(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> CalendarDay? {
        decision(for: item, today: today, now: now, calendar: calendar)?.nextDate
    }

    /// The current decision for `item`, or nil when the dates needed are missing.
    ///
    /// For a running subscription whose decision date for the next renewal is already
    /// past, the next renewal for which there is still time is used and
    /// `isTooLateThisRound` is set.
    static func decision(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> Decision? {
        if item.kind == .trial {
            guard let end = item.trialEnd else { return nil }
            let decisionDate = subtractNotice(from: end, value: item.noticeValue, unit: item.noticeUnit)
            return Decision(nextDate: end, relevantDate: end, decisionDate: decisionDate, isTooLateThisRound: false)
        }
        guard let anchor = item.anchor else { return nil }
        let interval = item.effectiveInterval
        guard interval.isRecurring else {
            let decisionDate = subtractNotice(from: anchor, value: item.noticeValue, unit: item.noticeUnit)
            return Decision(nextDate: anchor, relevantDate: anchor, decisionDate: decisionDate, isTooLateThisRound: false)
        }
        let first = firstRenewalIndex(anchor: anchor, interval: interval, onOrAfter: today)
        let next = renewal(anchor: anchor, interval: interval, index: first)
        var n = first
        // A notice period longer than several intervals can need more than one step.
        for _ in 0..<10_000 {
            let relevant = renewal(anchor: anchor, interval: interval, index: n)
            let decisionDate = subtractNotice(from: relevant, value: item.noticeValue, unit: item.noticeUnit)
            if decisionDate >= today {
                return Decision(nextDate: next, relevantDate: relevant, decisionDate: decisionDate, isTooLateThisRound: n > first)
            }
            n += 1
        }
        return nil
    }

    /// For a recurring subscription: the first decision whose decision date falls after
    /// `day`. Nil for trials and fixed end dates, which have only one decision.
    static func nextDecision(for item: ItemData, after day: CalendarDay, today: CalendarDay, now: Date, calendar: Calendar) -> Decision? {
        guard item.isRecurring, var current = decision(for: item, today: today, now: now, calendar: calendar),
              let anchor = item.anchor else { return nil }
        let interval = item.effectiveInterval
        var n = firstRenewalIndex(anchor: anchor, interval: interval, onOrAfter: current.relevantDate)
        for _ in 0..<10_000 {
            if current.decisionDate > day { return current }
            n += 1
            let relevant = renewal(anchor: anchor, interval: interval, index: n)
            let decisionDate = subtractNotice(from: relevant, value: item.noticeValue, unit: item.noticeUnit)
            current = Decision(nextDate: current.nextDate, relevantDate: relevant, decisionDate: decisionDate, isTooLateThisRound: current.isTooLateThisRound)
        }
        return nil
    }

    /// The current decision is already settled by Houden.
    static func isDecided(_ item: ItemData, decision: Decision) -> Bool {
        guard let decided = item.decidedThrough else { return false }
        return decision.decisionDate <= decided
    }

    /// The decision reminders are planned for: the current one, or for a recurring
    /// subscription whose current decision is settled, the next one.
    static func pendingDecision(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> Decision? {
        guard let current = decision(for: item, today: today, now: now, calendar: calendar) else { return nil }
        guard let decided = item.decidedThrough, current.decisionDate <= decided else { return current }
        return nextDecision(for: item, after: decided, today: today, now: now, calendar: calendar)
    }
}
