import Foundation
#if SWIFT_PACKAGE
@testable import OpzegwekkerCore
#else
@testable import Opzegwekker
#endif

/// Fixed clock and calendar for domain tests.
enum TestSupport {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Amsterdam")!
        calendar.locale = Locale(identifier: "nl_NL")
        return calendar
    }()

    static let settings = ReminderSettings()

    static func day(_ iso: String) -> CalendarDay {
        CalendarDay(isoString: iso)!
    }

    /// A moment in Amsterdam time, e.g. `moment("2026-10-04", 12, 0)`.
    static func moment(_ iso: String, _ hour: Int, _ minute: Int = 0) -> Date {
        day(iso).date(hour: hour, minute: minute, calendar: calendar)!
    }

    /// A UTC moment, e.g. `utc("2026-10-26T08:00:00Z")`.
    static func utc(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }

    static func trial(_ name: String = "Videoland", end: String, start: String? = nil, price: Int? = nil) -> ItemData {
        ItemData(
            name: name,
            kind: .trial,
            status: .trial,
            startDate: day(start ?? end),
            trialEnd: day(end),
            priceCents: price,
            createdAt: moment("2026-01-01", 12),
            updatedAt: moment("2026-01-01", 12)
        )
    }

    static func subscription(
        _ name: String = "NRC",
        anchor: String,
        interval: BillingInterval,
        price: Int? = nil,
        notice: Int = 0,
        unit: NoticeUnit = .days,
        status: Status = .active
    ) -> ItemData {
        ItemData(
            name: name,
            kind: .subscription,
            status: status,
            startDate: day("2026-01-01"),
            interval: interval,
            anchor: day(anchor),
            priceCents: price,
            noticeValue: notice,
            noticeUnit: unit,
            createdAt: moment("2026-01-01", 12),
            updatedAt: moment("2026-01-01", 12)
        )
    }
}
