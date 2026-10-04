import Foundation

/// The state of the add/edit form, and how it turns into an item.
struct ItemDraft: Hashable, Sendable {
    enum TrialLength: Hashable, Sendable {
        case days(Int)
        case date
    }

    /// Chip choices for "Eindigt over".
    static let trialChips = [7, 14, 30]

    var name: String
    var catalogID: String?
    var kind: Kind
    var trialLength: TrialLength
    var trialEnd: CalendarDay
    var interval: BillingInterval
    /// "Volgende verlenging", or "Loopt tot" for a fixed end date.
    var renewalDate: CalendarDay
    var priceText: String
    var startDate: CalendarDay
    var noticeValue: Int
    var noticeUnit: NoticeUnit
    var leadDaysOverride: Int?
    var remindersEnabledOverride: Bool?
    var cancelURL: String
    var note: String

    /// The item being edited, if any.
    var original: ItemData?
    /// The renewal date shown when editing started; the anchor only changes when the
    /// user picks another date, so a 31st anchor is not lost.
    var originalRenewalDate: CalendarDay?

    /// A new draft, filled from the catalog entry when there is one.
    init(name: String, service: CatalogService?, today: CalendarDay) {
        self.name = service?.name ?? name
        catalogID = service?.id
        kind = service?.defaultKind ?? .trial
        interval = service?.defaultInterval ?? .month
        if let days = service?.trialDays, days > 0 {
            trialLength = ItemDraft.trialChips.contains(days) ? .days(days) : .date
            trialEnd = today.adding(days: days)
        } else {
            trialLength = .days(30)
            trialEnd = today.adding(days: 30)
        }
        renewalDate = ItemDraft.oneInterval(after: today, interval: interval)
        priceText = ""
        startDate = today
        noticeValue = 0
        noticeUnit = .days
        leadDaysOverride = nil
        remindersEnabledOverride = nil
        cancelURL = service?.cancelURL ?? ""
        note = ""
        original = nil
        originalRenewalDate = nil
    }

    /// A draft for editing an existing item.
    init(item: ItemData, today: CalendarDay, now: Date, calendar: Calendar) {
        name = item.name
        catalogID = item.catalogID
        kind = item.kind
        interval = item.interval ?? .month
        let end = item.trialEnd ?? today.adding(days: 30)
        trialEnd = end
        trialLength = .date
        let renewal = item.kind == .subscription
            ? (DecisionRules.decision(for: item, today: today, now: now, calendar: calendar)?.nextDate ?? item.anchor ?? today)
            : ItemDraft.oneInterval(after: today, interval: interval)
        renewalDate = renewal
        originalRenewalDate = item.kind == .subscription ? renewal : nil
        priceText = item.priceCents.map(DutchFormat.editableAmount(cents:)) ?? ""
        startDate = item.startDate
        noticeValue = item.noticeValue
        noticeUnit = item.noticeUnit
        leadDaysOverride = item.leadDaysOverride
        remindersEnabledOverride = item.remindersEnabledOverride
        cancelURL = item.cancelURL ?? ""
        note = item.note
        original = item
    }

    static func oneInterval(after day: CalendarDay, interval: BillingInterval) -> CalendarDay {
        switch interval {
        case .week: day.adding(days: 7)
        case .month: day.adding(months: 1)
        case .quarter: day.adding(months: 3)
        case .year, .fixedEnd: day.adding(months: 12)
        }
    }

    mutating func selectTrialDays(_ days: Int, today: CalendarDay) {
        trialLength = .days(days)
        trialEnd = today.adding(days: days)
    }

    /// Changing the interval moves an untouched default renewal date along.
    mutating func selectInterval(_ newInterval: BillingInterval, today: CalendarDay) {
        let wasDefault = original == nil && renewalDate == ItemDraft.oneInterval(after: today, interval: interval)
        interval = newInterval
        if wasDefault {
            renewalDate = ItemDraft.oneInterval(after: today, interval: newInterval)
        }
    }

    /// The date the form's date field is about.
    var chosenDate: CalendarDay {
        kind == .trial ? trialEnd : renewalDate
    }

    /// "Deze datum is voorbij; waarschijnlijk loopt het al door."
    func isInPast(today: CalendarDay) -> Bool {
        chosenDate < today
    }

    var priceCents: Int? {
        DutchFormat.parseCents(priceText)
    }

    var trimmedName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Naamloos" : trimmed
    }

    /// Default first lead for the current form state.
    func defaultFirstLead(settings: ReminderSettings, today: CalendarDay, now: Date, calendar: Calendar) -> Int {
        var copy = self
        copy.leadDaysOverride = nil
        let item = copy.build(today: today, now: now, calendar: calendar)
        return ReminderRules.leads(for: item, settings: settings).first ?? 0
    }

    /// The "Seintje bij verlenging" toggle is shown for monthly and weekly subscriptions,
    /// whose reminders are off by default.
    var showsRenewalToggle: Bool {
        kind == .subscription && (interval == .month || interval == .week)
    }

    /// The item as it would be saved.
    func build(today: CalendarDay, now: Date, calendar: Calendar) -> ItemData {
        var item = original ?? ItemData(
            name: trimmedName,
            kind: kind,
            status: kind == .trial ? .trial : .active,
            startDate: startDate,
            createdAt: now,
            updatedAt: now
        )
        item.name = trimmedName
        item.catalogID = catalogID
        item.startDate = startDate
        item.priceCents = priceCents
        item.noticeValue = max(0, noticeValue)
        item.noticeUnit = noticeUnit
        item.leadDaysOverride = leadDaysOverride
        item.remindersEnabledOverride = remindersEnabledOverride
        let trimmedURL = cancelURL.trimmingCharacters(in: .whitespacesAndNewlines)
        item.cancelURL = trimmedURL.isEmpty ? nil : trimmedURL
        item.note = note
        item.updatedAt = now

        let keepsStatus = item.status == .cancelled || item.status == .stopped
        if kind == .trial {
            if trialEnd < today {
                // The trial is over, so it probably runs already.
                item.kind = .subscription
                item.interval = interval.isRecurring ? interval : .month
                item.anchor = trialEnd
                item.trialEnd = trialEnd
                if !keepsStatus { item.status = .active }
            } else {
                item.kind = .trial
                item.trialEnd = trialEnd
                item.interval = interval.isRecurring ? interval : nil
                item.anchor = nil
                if !keepsStatus { item.status = .trial }
            }
        } else {
            item.kind = .subscription
            item.trialEnd = original?.trialEnd
            if interval == .fixedEnd, renewalDate < today {
                // The fixed term has ended; it most likely continues monthly.
                item.interval = .month
                item.anchor = renewalDate
            } else {
                item.interval = interval
                if let originalRenewalDate, renewalDate == originalRenewalDate, original?.interval == interval,
                   let anchor = original?.anchor {
                    item.anchor = anchor
                } else {
                    item.anchor = renewalDate
                }
            }
            if !keepsStatus { item.status = .active }
        }
        if original == nil {
            item.needsConfirmation = false
        }
        return item
    }

    /// The live line under the date choice: "Eindigt do 3 nov · seintje di 1 nov",
    /// "Te laat voor deze ronde. Volgende kans: …" or the past-date warning.
    func liveLine(settings: ReminderSettings, today: CalendarDay, now: Date, calendar: Calendar) -> String {
        if isInPast(today: today) {
            return "Deze datum is voorbij; waarschijnlijk loopt het al door."
        }
        let item = build(today: today, now: now, calendar: calendar)
        guard let decision = DecisionRules.decision(for: item, today: today, now: now, calendar: calendar) else { return "" }
        if decision.isTooLateThisRound {
            return DetailTexts.tooLate(decision: decision, today: today)
        }
        let date = DutchFormat.short(decision.nextDate, today: today)
        var parts: [String]
        switch (item.kind, item.effectiveInterval) {
        case (.trial, _): parts = ["Eindigt \(date)"]
        case (_, .fixedEnd): parts = ["Loopt tot \(date)"]
        default: parts = ["Verlengt \(date)"]
        }
        if decision.decisionDate != decision.nextDate {
            parts.append("opzeggen vóór \(DutchFormat.short(decision.decisionDate, today: today))")
        }
        var probe = item
        probe.decidedThrough = nil
        probe.snoozeDay = nil
        if probe.status == .cancelled || probe.status == .stopped { probe.status = .active }
        if let first = ReminderRules.reminders(for: probe, settings: settings, today: today, now: now, calendar: calendar).first {
            parts.append("seintje \(DutchFormat.short(first.day, today: today))")
        } else if !ReminderRules.remindersEnabled(for: probe) {
            parts.append("geen seintje")
        }
        return parts.joined(separator: " · ")
    }
}
