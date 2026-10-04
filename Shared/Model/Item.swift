import Foundation
import SwiftData

/// A trial or subscription the user wants a reminder for.
///
/// Enums are stored as their String raw values and calendar days as `yyyy-MM-dd`
/// strings; typed accessors expose them as `Kind`, `Status`, `CalendarDay` and so on.
@Model
final class Item {
    @Attribute(.unique) var id: UUID
    var name: String
    var catalogID: String?
    var kindRaw: String
    var statusRaw: String
    var startDateRaw: String
    var trialEndRaw: String?
    var intervalRaw: String?
    var anchorRaw: String?
    var priceCents: Int?
    var noticeValue: Int
    var noticeUnitRaw: String
    var leadDaysOverride: Int?
    var remindersEnabledOverride: Bool?
    var cancelURL: String?
    var note: String
    var usableUntilRaw: String?
    var decidedThroughRaw: String?
    var snoozeDayRaw: String?
    var needsConfirmation: Bool
    var createdAt: Date
    var updatedAt: Date

    init(data: ItemData) {
        id = data.id
        name = data.name
        catalogID = data.catalogID
        kindRaw = data.kind.rawValue
        statusRaw = data.status.rawValue
        startDateRaw = data.startDate.isoString
        trialEndRaw = data.trialEnd?.isoString
        intervalRaw = data.interval?.rawValue
        anchorRaw = data.anchor?.isoString
        priceCents = data.priceCents
        noticeValue = data.noticeValue
        noticeUnitRaw = data.noticeUnit.rawValue
        leadDaysOverride = data.leadDaysOverride
        remindersEnabledOverride = data.remindersEnabledOverride
        cancelURL = data.cancelURL
        note = data.note
        usableUntilRaw = data.usableUntil?.isoString
        decidedThroughRaw = data.decidedThrough?.isoString
        snoozeDayRaw = data.snoozeDay?.isoString
        needsConfirmation = data.needsConfirmation
        createdAt = data.createdAt
        updatedAt = data.updatedAt
    }

    // MARK: - Typed accessors

    var kind: Kind {
        get { Kind(rawValue: kindRaw) ?? .subscription }
        set { kindRaw = newValue.rawValue }
    }

    var status: Status {
        get { Status(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var startDate: CalendarDay {
        get { CalendarDay(isoString: startDateRaw) ?? CalendarDay(createdAt, calendar: .current) }
        set { startDateRaw = newValue.isoString }
    }

    var trialEnd: CalendarDay? {
        get { trialEndRaw.flatMap(CalendarDay.init(isoString:)) }
        set { trialEndRaw = newValue?.isoString }
    }

    var interval: BillingInterval? {
        get { intervalRaw.flatMap(BillingInterval.init(rawValue:)) }
        set { intervalRaw = newValue?.rawValue }
    }

    var anchor: CalendarDay? {
        get { anchorRaw.flatMap(CalendarDay.init(isoString:)) }
        set { anchorRaw = newValue?.isoString }
    }

    var noticeUnit: NoticeUnit {
        get { NoticeUnit(rawValue: noticeUnitRaw) ?? .days }
        set { noticeUnitRaw = newValue.rawValue }
    }

    var usableUntil: CalendarDay? {
        get { usableUntilRaw.flatMap(CalendarDay.init(isoString:)) }
        set { usableUntilRaw = newValue?.isoString }
    }

    var decidedThrough: CalendarDay? {
        get { decidedThroughRaw.flatMap(CalendarDay.init(isoString:)) }
        set { decidedThroughRaw = newValue?.isoString }
    }

    var snoozeDay: CalendarDay? {
        get { snoozeDayRaw.flatMap(CalendarDay.init(isoString:)) }
        set { snoozeDayRaw = newValue?.isoString }
    }

    // MARK: - Value bridging

    var data: ItemData {
        ItemData(
            id: id,
            name: name,
            catalogID: catalogID,
            kind: kind,
            status: status,
            startDate: startDate,
            trialEnd: trialEnd,
            interval: interval,
            anchor: anchor,
            priceCents: priceCents,
            noticeValue: noticeValue,
            noticeUnit: noticeUnit,
            leadDaysOverride: leadDaysOverride,
            remindersEnabledOverride: remindersEnabledOverride,
            cancelURL: cancelURL,
            note: note,
            usableUntil: usableUntil,
            decidedThrough: decidedThrough,
            snoozeDay: snoozeDay,
            needsConfirmation: needsConfirmation,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    /// Copies every field except `id` from `data`. Only writes fields that changed,
    /// so SwiftData does not mark an untouched item as dirty.
    func apply(_ data: ItemData) {
        if name != data.name { name = data.name }
        if catalogID != data.catalogID { catalogID = data.catalogID }
        if kindRaw != data.kind.rawValue { kindRaw = data.kind.rawValue }
        if statusRaw != data.status.rawValue { statusRaw = data.status.rawValue }
        if startDateRaw != data.startDate.isoString { startDateRaw = data.startDate.isoString }
        if trialEndRaw != data.trialEnd?.isoString { trialEndRaw = data.trialEnd?.isoString }
        if intervalRaw != data.interval?.rawValue { intervalRaw = data.interval?.rawValue }
        if anchorRaw != data.anchor?.isoString { anchorRaw = data.anchor?.isoString }
        if priceCents != data.priceCents { priceCents = data.priceCents }
        if noticeValue != data.noticeValue { noticeValue = data.noticeValue }
        if noticeUnitRaw != data.noticeUnit.rawValue { noticeUnitRaw = data.noticeUnit.rawValue }
        if leadDaysOverride != data.leadDaysOverride { leadDaysOverride = data.leadDaysOverride }
        if remindersEnabledOverride != data.remindersEnabledOverride {
            remindersEnabledOverride = data.remindersEnabledOverride
        }
        if cancelURL != data.cancelURL { cancelURL = data.cancelURL }
        if note != data.note { note = data.note }
        if usableUntilRaw != data.usableUntil?.isoString { usableUntilRaw = data.usableUntil?.isoString }
        if decidedThroughRaw != data.decidedThrough?.isoString {
            decidedThroughRaw = data.decidedThrough?.isoString
        }
        if snoozeDayRaw != data.snoozeDay?.isoString { snoozeDayRaw = data.snoozeDay?.isoString }
        if needsConfirmation != data.needsConfirmation { needsConfirmation = data.needsConfirmation }
        if createdAt != data.createdAt { createdAt = data.createdAt }
        if updatedAt != data.updatedAt { updatedAt = data.updatedAt }
    }
}
