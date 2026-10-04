import Foundation

enum Kind: String, Codable, CaseIterable, Sendable {
    case trial
    case subscription
}

enum Status: String, Codable, CaseIterable, Sendable {
    case trial
    case active
    case cancelled
    case stopped
}

enum BillingInterval: String, Codable, CaseIterable, Sendable {
    case week
    case month
    case quarter
    case year
    case fixedEnd

    /// True for intervals that renew by themselves.
    var isRecurring: Bool { self != .fixedEnd }
}

enum NoticeUnit: String, Codable, CaseIterable, Sendable {
    case days
    case months
}

/// A plain value copy of an `Item`.
///
/// The domain layer works on this type only, so it can be tested without SwiftData.
/// It also serves as the snapshot used to undo a delete.
struct ItemData: Identifiable, Hashable, Codable, Sendable {
    var id: UUID
    var name: String
    var catalogID: String?
    var kind: Kind
    var status: Status
    var startDate: CalendarDay
    var trialEnd: CalendarDay?
    var interval: BillingInterval?
    var anchor: CalendarDay?
    var priceCents: Int?
    var noticeValue: Int
    var noticeUnit: NoticeUnit
    var leadDaysOverride: Int?
    var remindersEnabledOverride: Bool?
    var cancelURL: String?
    var note: String
    var usableUntil: CalendarDay?
    var decidedThrough: CalendarDay?
    var snoozeDay: CalendarDay?
    var needsConfirmation: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        catalogID: String? = nil,
        kind: Kind,
        status: Status,
        startDate: CalendarDay,
        trialEnd: CalendarDay? = nil,
        interval: BillingInterval? = nil,
        anchor: CalendarDay? = nil,
        priceCents: Int? = nil,
        noticeValue: Int = 0,
        noticeUnit: NoticeUnit = .days,
        leadDaysOverride: Int? = nil,
        remindersEnabledOverride: Bool? = nil,
        cancelURL: String? = nil,
        note: String = "",
        usableUntil: CalendarDay? = nil,
        decidedThrough: CalendarDay? = nil,
        snoozeDay: CalendarDay? = nil,
        needsConfirmation: Bool = false,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.catalogID = catalogID
        self.kind = kind
        self.status = status
        self.startDate = startDate
        self.trialEnd = trialEnd
        self.interval = interval
        self.anchor = anchor
        self.priceCents = priceCents
        self.noticeValue = noticeValue
        self.noticeUnit = noticeUnit
        self.leadDaysOverride = leadDaysOverride
        self.remindersEnabledOverride = remindersEnabledOverride
        self.cancelURL = cancelURL
        self.note = note
        self.usableUntil = usableUntil
        self.decidedThrough = decidedThrough
        self.snoozeDay = snoozeDay
        self.needsConfirmation = needsConfirmation
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// The interval used for scheduling. A subscription without one counts as monthly.
    var effectiveInterval: BillingInterval {
        interval ?? .month
    }

    /// True when the item renews by itself (a subscription with a recurring interval).
    var isRecurring: Bool {
        kind == .subscription && effectiveInterval.isRecurring
    }

    var isLive: Bool {
        status == .trial || status == .active
    }
}

/// User preferences that influence scheduling.
struct ReminderSettings: Codable, Hashable, Sendable {
    var hour: Int = 9
    var minute: Int = 0
    var trialLeadDays: Int = 2
    var yearLeadDays: Int = 14
    var badgeEnabled: Bool = true
}
