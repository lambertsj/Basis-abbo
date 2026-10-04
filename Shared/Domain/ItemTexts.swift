import Foundation

/// The texts shown for an item in rows, the detail screen, the widget and VoiceOver.
struct ItemTexts: Hashable, Sendable {
    /// Row subtitle, e.g. "Proef eindigt do 3 nov".
    var subtitle: String
    /// Remaining days until the decision (or the end of a cancellation), if any.
    var daysLeft: Int?
    /// "vandaag", "morgen", "nog 3 dagen".
    var daysLeftText: String?
    var urgency: Urgency
    /// "Videoland, proef eindigt donderdag 3 november, nog 5 dagen"
    var accessibilityLabel: String

    init(item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) {
        let decision = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)
        var spoken: String

        switch item.status {
        case .cancelled:
            if let until = item.usableUntil {
                subtitle = "Loopt af op \(DutchFormat.dayMonth(until, today: today))"
                spoken = "loopt af op \(DutchFormat.long(until))"
                daysLeft = today.days(until: until)
            } else {
                subtitle = "Opgezegd"
                spoken = "opgezegd"
                daysLeft = nil
            }
        case .stopped:
            if let until = item.usableUntil {
                subtitle = "Gestopt op \(DutchFormat.dayMonth(until, today: today))"
                spoken = "gestopt op \(DutchFormat.long(until))"
            } else {
                subtitle = "Gestopt"
                spoken = "gestopt"
            }
            daysLeft = nil
        case .trial, .active:
            daysLeft = decision.map { today.days(until: $0.decisionDate) }
            if item.kind == .trial, let end = item.trialEnd {
                subtitle = "Proef eindigt \(DutchFormat.short(end, today: today))"
                spoken = "proef eindigt \(DutchFormat.long(end))"
            } else if item.effectiveInterval == .fixedEnd, let end = item.anchor {
                subtitle = "Loopt af \(DutchFormat.dayMonth(end, today: today))"
                spoken = "loopt af \(DutchFormat.long(end))"
            } else if let next = decision?.nextDate {
                let date = DutchFormat.dayMonth(next, today: today)
                if let price = item.priceCents {
                    let amount = "\(DutchFormat.euro(cents: price)) \(DutchFormat.perInterval(item.effectiveInterval))"
                    subtitle = "\(amount) · verlengt \(date)"
                    spoken = "\(amount), verlengt \(DutchFormat.long(next))"
                } else {
                    subtitle = "Verlengt \(date)"
                    spoken = "verlengt \(DutchFormat.long(next))"
                }
            } else {
                subtitle = item.kind == .trial ? "Proef" : "Abonnement"
                spoken = subtitle.lowercased()
            }
        }

        daysLeftText = daysLeft.map(DutchFormat.remainingDays)
        urgency = daysLeft.map(Urgency.init(daysLeft:)) ?? .normal
        if let daysLeftText {
            spoken += ", \(daysLeftText)"
        }
        accessibilityLabel = "\(item.name), \(spoken)"
    }
}

/// Texts for the head of the detail screen.
struct DetailTexts: Hashable, Sendable {
    /// "Beslis vóór wo 2 nov" or "Loopt af op 3 nov".
    var headline: String
    /// "nog 5 dagen · daarna € 9,99 per maand"
    var subline: String?
    /// "Te laat voor deze ronde. Volgende kans: 10 sep 2027."
    var tooLateNote: String?

    init(item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) {
        tooLateNote = nil
        switch item.status {
        case .cancelled:
            headline = item.usableUntil.map { "Loopt af op \(DutchFormat.dayMonth($0, today: today))" } ?? "Opgezegd"
            subline = item.usableUntil.map { DutchFormat.remainingDays(today.days(until: $0)) }
        case .stopped:
            headline = item.usableUntil.map { "Gestopt op \(DutchFormat.dayMonth($0, today: today))" } ?? "Gestopt"
            subline = nil
        case .trial, .active:
            guard let decision = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar) else {
                headline = item.name
                subline = nil
                return
            }
            headline = "Beslis vóór \(DutchFormat.short(decision.decisionDate, today: today))"
            var parts = [DutchFormat.remainingDays(today.days(until: decision.decisionDate))]
            if let price = item.priceCents {
                let amount = "\(DutchFormat.euro(cents: price)) \(DutchFormat.perInterval(item.effectiveInterval))"
                parts.append(item.kind == .trial ? "daarna \(amount)" : amount)
            }
            subline = parts.joined(separator: " · ")
            if decision.isTooLateThisRound {
                tooLateNote = DetailTexts.tooLate(decision: decision, today: today)
            }
        }
    }

    /// "Te laat voor deze ronde. Volgende kans: <datum>."
    static func tooLate(decision: Decision, today: CalendarDay) -> String {
        "Te laat voor deze ronde. Volgende kans: \(DutchFormat.short(decision.decisionDate, today: today))."
    }
}
