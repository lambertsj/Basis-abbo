import Foundation

/// Automatic state changes as days pass. Run at app start, on return to the foreground
/// and in the background task. Applying them twice has the same result as once.
enum Transitions {
    /// Applies all transitions to `item`. Returns true when something changed.
    /// - Parameter defaultInterval: the catalog's `defaultInterval` for the item, if any.
    @discardableResult
    static func apply(to item: inout ItemData, defaultInterval: BillingInterval?, today: CalendarDay, now: Date, calendar: Calendar) -> Bool {
        let before = item

        // 1. Expired trial: it now probably continues as a paid subscription.
        if item.status == .trial, let end = item.trialEnd, end < today {
            let decisionDate = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)?.decisionDate ?? end
            let alreadyKept = item.decidedThrough.map { $0 >= decisionDate } ?? false
            item.status = .active
            item.kind = .subscription
            item.interval = defaultInterval.flatMap { $0.isRecurring ? $0 : nil } ?? .month
            item.anchor = end
            item.needsConfirmation = !alreadyKept
        }

        // 1b. Passed fixed end date: under Dutch law the contract then usually continues
        // monthly. Treat it like an expired trial and ask the user to confirm.
        if item.status == .active, item.kind == .subscription, item.interval == .fixedEnd,
           let end = item.anchor, end < today {
            let decisionDate = DecisionRules.subtractNotice(from: end, value: item.noticeValue, unit: item.noticeUnit)
            let alreadyKept = item.decidedThrough.map { $0 >= decisionDate } ?? false
            item.interval = .month
            // The fixed-end price is already per month, so it stays as is.
            item.needsConfirmation = !alreadyKept
        }

        // 2. Cancellation ran out.
        if item.status == .cancelled, let until = item.usableUntil, until < today {
            item.status = .stopped
        }

        // 3. Old snooze.
        if let snooze = item.snoozeDay, snooze < today {
            item.snoozeDay = nil
        }

        guard item != before else { return false }
        item.updatedAt = now
        return true
    }
}
