import Foundation

/// Dutch text formatting for dates, amounts and relative days.
///
/// Short notation follows the app's style ("do 3 nov", "14 mrt"): CLDR's nl_NL
/// abbreviations add a period to most months ("nov."), so fixed name tables are used
/// that match the `nl_NL` day and month names without the period. This also keeps the
/// output identical on every OS version.
enum DutchFormat {
    static let locale = Locale(identifier: "nl_NL")

    private static let weekdaysShort = ["zo", "ma", "di", "wo", "do", "vr", "za"]
    private static let weekdaysLong = ["zondag", "maandag", "dinsdag", "woensdag", "donderdag", "vrijdag", "zaterdag"]
    private static let monthsShort = ["jan", "feb", "mrt", "apr", "mei", "jun", "jul", "aug", "sep", "okt", "nov", "dec"]
    private static let monthsLong = [
        "januari", "februari", "maart", "april", "mei", "juni",
        "juli", "augustus", "september", "oktober", "november", "december",
    ]

    // MARK: - Dates

    /// "do 3 nov"
    static func short(_ day: CalendarDay) -> String {
        "\(weekdaysShort[day.weekday - 1]) \(dayMonth(day))"
    }

    /// "3 nov"
    static func dayMonth(_ day: CalendarDay) -> String {
        "\(day.day) \(monthsShort[day.month - 1])"
    }

    /// "3 nov 2027" when the year differs from `today`'s, else "3 nov".
    static func dayMonth(_ day: CalendarDay, today: CalendarDay) -> String {
        day.year == today.year ? dayMonth(day) : "\(dayMonth(day)) \(day.year)"
    }

    /// "do 3 nov", with the year added when it differs from `today`'s.
    static func short(_ day: CalendarDay, today: CalendarDay) -> String {
        day.year == today.year ? short(day) : "\(short(day)) \(day.year)"
    }

    /// "donderdag 3 november"
    static func long(_ day: CalendarDay) -> String {
        "\(weekdayName(day)) \(day.day) \(monthsLong[day.month - 1])"
    }

    /// "donderdag"
    static func weekdayName(_ day: CalendarDay) -> String {
        weekdaysLong[day.weekday - 1]
    }

    /// "vandaag", "morgen", a weekday within the coming week, else "3 nov".
    static func relativeDay(_ day: CalendarDay, from reference: CalendarDay) -> String {
        switch reference.days(until: day) {
        case 0: "vandaag"
        case 1: "morgen"
        case 2...6: weekdayName(day)
        default: dayMonth(day, today: reference)
        }
    }

    /// "vandaag", "morgen", "nog 3 dagen"; "voorbij" for a past day.
    static func remainingDays(_ days: Int) -> String {
        switch days {
        case ..<0: "voorbij"
        case 0: "vandaag"
        case 1: "morgen"
        default: "nog \(days) dagen"
        }
    }

    // MARK: - Amounts

    /// "€ 9,99", or "€ 79" for whole euros. Thousands get a dot: "€ 1.200".
    static func euro(cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        let value = abs(cents)
        let euros = grouped(value / 100)
        let rest = value % 100
        if rest == 0 {
            return "\(sign)€ \(euros)"
        }
        return "\(sign)€ \(euros),\(String(format: "%02d", rest))"
    }

    /// Whole euros, rounded half away from zero: "€ 33".
    static func euroRounded(cents: Double) -> String {
        let euros = Int((cents / 100).rounded(.toNearestOrAwayFromZero))
        return "€ \(grouped(euros))"
    }

    private static func grouped(_ value: Int) -> String {
        let digits = String(value)
        var result = ""
        for (index, character) in digits.enumerated() {
            if index > 0, (digits.count - index) % 3 == 0 { result.append(".") }
            result.append(character)
        }
        return result
    }

    /// Parses "9,99", "9.99", "€ 10" or "1.200,50" into cents. Nil when empty or invalid.
    static func parseCents(_ text: String) -> Int? {
        var cleaned = text.replacingOccurrences(of: "€", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
        guard !cleaned.isEmpty else { return nil }
        if cleaned.contains(",") {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
        } else if let dot = cleaned.lastIndex(of: "."), cleaned.distance(from: dot, to: cleaned.endIndex) == 4 {
            // "1.200" is a thousands separator, not a decimal point.
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
        }
        guard let value = Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX")), value >= 0 else { return nil }
        var cents = value * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &cents, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    /// Cents as text for an input field: "9,99" or "10".
    static func editableAmount(cents: Int) -> String {
        cents % 100 == 0 ? String(cents / 100) : "\(cents / 100),\(String(format: "%02d", cents % 100))"
    }

    /// "per maand", "per jaar" …
    static func perInterval(_ interval: BillingInterval) -> String {
        switch interval {
        case .week: "per week"
        case .month, .fixedEnd: "per maand"
        case .quarter: "per kwartaal"
        case .year: "per jaar"
        }
    }

    /// "Week", "Maand" … as used in pickers.
    static func intervalName(_ interval: BillingInterval) -> String {
        switch interval {
        case .week: "Week"
        case .month: "Maand"
        case .quarter: "Kwartaal"
        case .year: "Jaar"
        case .fixedEnd: "Vaste einddatum"
        }
    }

    /// "1 maand", "14 dagen"
    static func notice(value: Int, unit: NoticeUnit) -> String {
        switch unit {
        case .days: value == 1 ? "1 dag" : "\(value) dagen"
        case .months: value == 1 ? "1 maand" : "\(value) maanden"
        }
    }

    /// "1 dag", "3 dagen"
    static func days(_ value: Int) -> String {
        value == 1 ? "1 dag" : "\(value) dagen"
    }

    /// "Videoland en NRC", "A, B en C", "A, B en 2 andere".
    static func nameList(_ names: [String]) -> String {
        switch names.count {
        case 0: return ""
        case 1: return names[0]
        case 2: return "\(names[0]) en \(names[1])"
        case 3: return "\(names[0]), \(names[1]) en \(names[2])"
        default: return "\(names[0]), \(names[1]) en \(names.count - 2) andere"
        }
    }
}
