import Foundation

/// What the user can do with an item, as pure state changes.
enum ItemActions {
    /// Houden: settles the decision reminders are currently about.
    /// Returns the message to show briefly.
    @discardableResult
    static func keep(_ item: inout ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> String {
        guard let decision = DecisionRules.pendingDecision(for: item, today: today, now: now, calendar: calendar) else {
            return keptMessage(for: item, today: today, now: now, calendar: calendar)
        }
        item.decidedThrough = max(item.decidedThrough ?? decision.decisionDate, decision.decisionDate)
        item.snoozeDay = nil
        item.updatedAt = now
        return keptMessage(for: item, today: today, now: now, calendar: calendar)
    }

    /// "Je krijgt weer een seintje vóór <volgende beslisdatum>" or, for a trial,
    /// "Geen seintjes meer voor deze proef".
    static func keptMessage(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> String {
        if item.kind == .trial {
            return "Geen seintjes meer voor deze proef"
        }
        guard item.isRecurring,
              let next = DecisionRules.pendingDecision(for: item, today: today, now: now, calendar: calendar)
        else { return "Geen seintjes meer hiervoor" }
        return "Je krijgt weer een seintje vóór \(DutchFormat.short(next.decisionDate, today: today))"
    }

    /// Morgen opnieuw: the earlier of tomorrow and the decision date.
    static func snooze(_ item: inout ItemData, today: CalendarDay, now: Date, calendar: Calendar) {
        let tomorrow = today.adding(days: 1)
        if let decision = DecisionRules.pendingDecision(for: item, today: today, now: now, calendar: calendar) {
            item.snoozeDay = min(tomorrow, decision.decisionDate)
        } else {
            item.snoozeDay = tomorrow
        }
        item.updatedAt = now
    }

    /// Opgezegd: usable until the given day (by default the relevant date).
    static func markCancelled(_ item: inout ItemData, usableUntil: CalendarDay, now: Date) {
        item.status = .cancelled
        item.usableUntil = usableUntil
        item.needsConfirmation = false
        item.snoozeDay = nil
        item.updatedAt = now
    }

    /// The default for "Tot wanneer kun je het nog gebruiken?": the relevant date.
    static func defaultUsableUntil(for item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) -> CalendarDay {
        DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)?.nextDate ?? today
    }

    /// Toch niet opgezegd: back to trial when the trial has not ended yet, else active.
    static func undoCancel(_ item: inout ItemData, today: CalendarDay, now: Date) {
        if item.kind == .trial, let end = item.trialEnd, end >= today {
            item.status = .trial
        } else {
            item.status = .active
            if item.kind == .trial {
                // The trial is over; it continues as a subscription from its end date.
                item.kind = .subscription
                item.anchor = item.trialEnd ?? item.anchor
                item.interval = item.interval.flatMap { $0.isRecurring ? $0 : nil } ?? .month
            }
        }
        item.usableUntil = nil
        item.updatedAt = now
    }

    /// Card "Klopt": it continues.
    static func confirmContinues(_ item: inout ItemData, now: Date) {
        item.needsConfirmation = false
        item.updatedAt = now
    }

    /// Card "Ik had al opgezegd": stopped as of the end of the trial or term.
    static func alreadyCancelled(_ item: inout ItemData, today: CalendarDay, now: Date) {
        item.status = .stopped
        item.needsConfirmation = false
        if item.usableUntil == nil {
            item.usableUntil = item.anchor.map { min($0, today) } ?? today
        }
        item.updatedAt = now
    }
}
