import Foundation

/// CSV export that Excel with Dutch settings opens correctly: UTF-8 with BOM,
/// semicolons as separator, decimal comma in amounts.
enum CSVExport {
    static let header = [
        "id", "naam", "catalogus_id", "soort", "status", "startdatum", "proef_einde",
        "interval", "anker", "prijs_eur", "opzegtermijn", "opzegtermijn_eenheid",
        "seintje_vooraf_dagen", "seintjes_aan", "opzeglink", "notitie", "bruikbaar_tot",
        "besloten_tot_en_met", "snooze_dag", "bevestiging_nodig", "aangemaakt", "gewijzigd",
    ]

    static func make(_ items: [ItemData]) -> String {
        var lines = [header.joined(separator: ";")]
        let timestamp = ISO8601DateFormatter()
        for item in items.sorted(by: { $0.createdAt < $1.createdAt }) {
            let fields: [String] = [
                item.id.uuidString,
                item.name,
                item.catalogID ?? "",
                item.kind.rawValue,
                item.status.rawValue,
                item.startDate.isoString,
                item.trialEnd?.isoString ?? "",
                item.interval?.rawValue ?? "",
                item.anchor?.isoString ?? "",
                item.priceCents.map(amount) ?? "",
                String(item.noticeValue),
                item.noticeUnit.rawValue,
                item.leadDaysOverride.map(String.init) ?? "",
                item.remindersEnabledOverride.map { $0 ? "ja" : "nee" } ?? "",
                item.cancelURL ?? "",
                item.note,
                item.usableUntil?.isoString ?? "",
                item.decidedThrough?.isoString ?? "",
                item.snoozeDay?.isoString ?? "",
                item.needsConfirmation ? "ja" : "nee",
                timestamp.string(from: item.createdAt),
                timestamp.string(from: item.updatedAt),
            ]
            lines.append(fields.map(escape).joined(separator: ";"))
        }
        return "\u{FEFF}" + lines.joined(separator: "\r\n") + "\r\n"
    }

    /// "9,99"
    static func amount(_ cents: Int) -> String {
        let sign = cents < 0 ? "-" : ""
        return "\(sign)\(abs(cents) / 100),\(String(format: "%02d", abs(cents) % 100))"
    }

    static func escape(_ field: String) -> String {
        guard field.contains(where: { $0 == ";" || $0 == "\"" || $0 == "\n" || $0 == "\r" }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// `opzegwekker-2026-10-04.csv`
    static func fileName(today: CalendarDay) -> String {
        "opzegwekker-\(today.isoString).csv"
    }
}
