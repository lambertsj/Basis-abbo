import Foundation

/// A calendar day without a time or time zone.
///
/// All dates in the app are calendar days. Only when a notification is scheduled is a
/// day combined with the chosen time of day and turned into `DateComponents` in the
/// current time zone, so 09:00 stays 09:00 across daylight saving changes and travel.
///
/// Day arithmetic is done on the proleptic Gregorian calendar with pure integer math,
/// so it never depends on a time zone and never fails.
struct CalendarDay: Codable, Hashable, Comparable, Sendable, CustomStringConvertible {
    var year: Int
    var month: Int
    var day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// The calendar day that `date` falls on in `calendar`'s time zone.
    init(_ date: Date, calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: components.year ?? 1970, month: components.month ?? 1, day: components.day ?? 1)
    }

    static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    var description: String { isoString }

    // MARK: - Arithmetic

    /// Number of days since 1970-01-01 (may be negative).
    var dayNumber: Int {
        // Howard Hinnant's days_from_civil.
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yoe = y - era * 400
        let mp = (month + 9) % 12
        let doy = (153 * mp + 2) / 5 + day - 1
        let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy
        return era * 146_097 + doe - 719_468
    }

    init(dayNumber: Int) {
        // Howard Hinnant's civil_from_days.
        let z = dayNumber + 719_468
        let era = (z >= 0 ? z : z - 146_096) / 146_097
        let doe = z - era * 146_097
        let yoe = (doe - doe / 1460 + doe / 36524 - doe / 146_096) / 365
        let doy = doe - (365 * yoe + yoe / 4 - yoe / 100)
        let mp = (5 * doy + 2) / 153
        let d = doy - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        self.init(year: yoe + era * 400 + (m <= 2 ? 1 : 0), month: m, day: d)
    }

    func adding(days: Int) -> CalendarDay {
        CalendarDay(dayNumber: dayNumber + days)
    }

    /// Adds calendar months; the day is clamped to the length of the target month
    /// (2027-01-31 + 1 month = 2027-02-28).
    func adding(months: Int) -> CalendarDay {
        let index = year * 12 + (month - 1) + months
        let newYear = index >= 0 ? index / 12 : (index - 11) / 12
        let newMonth = index - newYear * 12 + 1
        let length = CalendarDay.daysInMonth(year: newYear, month: newMonth)
        return CalendarDay(year: newYear, month: newMonth, day: min(day, length))
    }

    /// Whole days from `self` to `other` (positive when `other` is later).
    func days(until other: CalendarDay) -> Int {
        other.dayNumber - dayNumber
    }

    /// 1 = Sunday … 7 = Saturday, matching `Calendar.component(.weekday, …)`.
    var weekday: Int {
        let n = (dayNumber + 4) % 7 // 1970-01-01 was a Thursday (index 4, Sunday = 0)
        return (n >= 0 ? n : n + 7) + 1
    }

    static func daysInMonth(year: Int, month: Int) -> Int {
        switch month {
        case 2:
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    // MARK: - Conversion

    /// Components for this day at the given time, without a time zone, so they are
    /// interpreted in the current time zone when a notification fires.
    func dateComponents(hour: Int, minute: Int) -> DateComponents {
        DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
    }

    /// The moment this day reaches `hour:minute` in `calendar`'s time zone.
    func date(hour: Int, minute: Int, calendar: Calendar) -> Date? {
        calendar.date(from: dateComponents(hour: hour, minute: minute))
    }

    /// `yyyy-MM-dd`
    var isoString: String {
        let y = String(format: "%04d", year)
        let m = String(format: "%02d", month)
        let d = String(format: "%02d", day)
        return "\(y)-\(m)-\(d)"
    }

    init?(isoString: String) {
        let parts = isoString.split(separator: "-")
        guard parts.count == 3,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]),
              (1...12).contains(m), d >= 1, d <= CalendarDay.daysInMonth(year: y, month: m)
        else { return nil }
        self.init(year: y, month: m, day: d)
    }
}
