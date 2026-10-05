import Foundation
import Testing
#if SWIFT_PACKAGE
@testable import OpzegwekkerCore
#else
@testable import Opzegwekker
#endif

@Suite("CalendarDay")
struct CalendarDayTests {
    @Test func arithmetic() {
        let day = TestSupport.day("2027-01-31")
        #expect(day.adding(months: 1) == TestSupport.day("2027-02-28"))
        #expect(day.adding(months: 13) == TestSupport.day("2028-02-29"))
        #expect(day.adding(months: -2) == TestSupport.day("2026-11-30"))
        #expect(day.adding(days: 1) == TestSupport.day("2027-02-01"))
        #expect(TestSupport.day("2026-12-31").adding(days: 1) == TestSupport.day("2027-01-01"))
        #expect(TestSupport.day("2026-10-01").days(until: TestSupport.day("2026-10-31")) == 30)
        #expect(CalendarDay(dayNumber: day.dayNumber) == day)
    }

    @Test func weekday() {
        // 2026-10-04 is a Sunday; 2026-11-03 a Tuesday.
        #expect(TestSupport.day("2026-10-04").weekday == 1)
        #expect(TestSupport.day("2026-11-03").weekday == 3)
        let date = TestSupport.moment("2026-11-03", 12)
        #expect(TestSupport.calendar.component(.weekday, from: date) == 3)
    }

    @Test func conversion() {
        let date = TestSupport.utc("2026-10-25T23:30:00Z") // 00:30 on the 26th in Amsterdam
        #expect(CalendarDay(date, calendar: TestSupport.calendar) == TestSupport.day("2026-10-26"))
        #expect(CalendarDay(isoString: "2026-02-30") == nil)
        #expect(CalendarDay(isoString: "2026-13-01") == nil)
        #expect(TestSupport.day("2026-03-05").isoString == "2026-03-05")
    }
}

@Suite("Opmaak")
struct FormatTests {
    @Test func dates() {
        let day = TestSupport.day("2026-11-05")
        #expect(DutchFormat.short(day) == "do 5 nov")
        #expect(DutchFormat.dayMonth(TestSupport.day("2027-03-14")) == "14 mrt")
        #expect(DutchFormat.long(day) == "donderdag 5 november")
        #expect(DutchFormat.relativeDay(day, from: day) == "vandaag")
        #expect(DutchFormat.relativeDay(day, from: day.adding(days: -1)) == "morgen")
        #expect(DutchFormat.relativeDay(day, from: day.adding(days: -3)) == "donderdag")
        #expect(DutchFormat.relativeDay(day, from: day.adding(days: -10)) == "5 nov")
    }

    @Test func remainingDays() {
        #expect(DutchFormat.remainingDays(0) == "vandaag")
        #expect(DutchFormat.remainingDays(1) == "morgen")
        #expect(DutchFormat.remainingDays(3) == "nog 3 dagen")
        #expect(Urgency(daysLeft: 2) == .high)
        #expect(Urgency(daysLeft: 7) == .medium)
        #expect(Urgency(daysLeft: 8) == .normal)
    }

    @Test func amounts() {
        #expect(DutchFormat.euro(cents: 999) == "€ 9,99")
        #expect(DutchFormat.euro(cents: 7900) == "€ 79")
        #expect(DutchFormat.euro(cents: 120_050) == "€ 1.200,50")
        #expect(DutchFormat.parseCents("9,99") == 999)
        #expect(DutchFormat.parseCents("9.99") == 999)
        #expect(DutchFormat.parseCents("€ 10") == 1000)
        #expect(DutchFormat.parseCents("1.200") == 120_000)
        #expect(DutchFormat.parseCents("1.200,5") == 120_050)
        #expect(DutchFormat.parseCents("") == nil)
        #expect(DutchFormat.parseCents("abc") == nil)
        #expect(DutchFormat.editableAmount(cents: 999) == "9,99")
    }

    @Test func nameList() {
        #expect(DutchFormat.nameList(["Videoland", "NRC"]) == "Videoland en NRC")
        #expect(DutchFormat.nameList(["A", "B", "C"]) == "A, B en C")
        #expect(DutchFormat.nameList(["Videoland", "NRC", "C", "D"]) == "Videoland, NRC en 2 andere")
    }
}

@Suite("Teksten")
struct TextTests {
    let calendar = TestSupport.calendar
    let today = TestSupport.day("2026-10-29")
    let now = TestSupport.moment("2026-10-29", 12)

    @Test func rowTexts() {
        let trial = TestSupport.trial(end: "2026-11-03")
        let texts = ItemTexts(item: trial, today: today, now: now, calendar: calendar)
        #expect(texts.subtitle == "Proef eindigt di 3 nov")
        #expect(texts.daysLeftText == "nog 5 dagen")
        #expect(texts.accessibilityLabel == "Videoland, proef eindigt dinsdag 3 november, nog 5 dagen")

        let yearly = TestSupport.subscription("Magazine", anchor: "2027-03-14", interval: .year, price: 7900)
        #expect(ItemTexts(item: yearly, today: today, now: now, calendar: calendar).subtitle == "€ 79 per jaar · verlengt 14 mrt 2027")
        let noPrice = TestSupport.subscription("Magazine", anchor: "2026-11-14", interval: .month)
        #expect(ItemTexts(item: noPrice, today: today, now: now, calendar: calendar).subtitle == "Verlengt 14 nov")
        let fixed = TestSupport.subscription("Sportschool", anchor: "2027-06-01", interval: .fixedEnd)
        #expect(ItemTexts(item: fixed, today: today, now: now, calendar: calendar).subtitle == "Loopt af 1 jun 2027")

        var cancelled = trial
        cancelled.status = .cancelled
        cancelled.usableUntil = TestSupport.day("2026-11-03")
        #expect(ItemTexts(item: cancelled, today: today, now: now, calendar: calendar).subtitle == "Loopt af op 3 nov")
        cancelled.status = .stopped
        #expect(ItemTexts(item: cancelled, today: today, now: now, calendar: calendar).subtitle == "Gestopt op 3 nov")
    }

    @Test func detailTexts() {
        let trial = TestSupport.trial(end: "2026-11-03", price: 999)
        let texts = DetailTexts(item: trial, today: today, now: now, calendar: calendar)
        #expect(texts.headline == "Beslis vóór di 3 nov")
        #expect(texts.subline == "nog 5 dagen · daarna € 9,99 per maand")
        #expect(texts.tooLateNote == nil)
    }

    @Test func notificationTexts() throws {
        let item = TestSupport.trial(end: "2026-11-03", price: 999)
        let planned = NotificationPlanner.plan(items: [item], settings: TestSupport.settings, today: today, now: now, calendar: calendar)
        #expect(planned.count == 2)
        let first = try #require(planned.first)
        #expect(first.title == "Videoland: proef eindigt dinsdag")
        #expect(first.body == "Wil je stoppen? Zeg op vóór di 3 nov. Daarna € 9,99 per maand.")
        #expect(first.category == .decision)
        let last = try #require(planned.last)
        #expect(last.title == "Videoland: proef eindigt vandaag")
        #expect(last.body == "Laatste dag om kosteloos op te zeggen. Daarna € 9,99 per maand.")

        let renewal = TestSupport.subscription("NRC", anchor: "2026-11-01", interval: .quarter)
        let renewalPlan = NotificationPlanner.plan(items: [renewal], settings: TestSupport.settings, today: TestSupport.day("2026-10-20"), now: TestSupport.moment("2026-10-20", 8), calendar: calendar)
        #expect(renewalPlan.first?.title == "NRC: verlengt 1 nov")
    }
}

@Suite("Domeinregels")
struct RuleTests {
    let calendar = TestSupport.calendar
    let settings = TestSupport.settings
    let today = TestSupport.day("2026-10-04")
    let now = TestSupport.moment("2026-10-04", 8)

    @Test func defaultLeadsAndEnabled() {
        let monthly = TestSupport.subscription(anchor: "2026-10-10", interval: .month)
        #expect(ReminderRules.leads(for: monthly, settings: settings) == [2])
        #expect(!ReminderRules.remindersEnabled(for: monthly))
        #expect(ReminderRules.reminders(for: monthly, settings: settings, today: today, now: now, calendar: calendar).isEmpty)

        var enabled = monthly
        enabled.remindersEnabledOverride = true
        #expect(ReminderRules.reminders(for: enabled, settings: settings, today: today, now: now, calendar: calendar).map(\.day) == [TestSupport.day("2026-10-08")])

        let quarter = TestSupport.subscription(anchor: "2026-12-01", interval: .quarter)
        #expect(ReminderRules.leads(for: quarter, settings: settings) == [7])
        let fixed = TestSupport.subscription(anchor: "2027-06-01", interval: .fixedEnd)
        #expect(ReminderRules.leads(for: fixed, settings: settings) == [30, 7])

        var custom = TestSupport.trial(end: "2026-10-20")
        custom.leadDaysOverride = 5
        #expect(ReminderRules.leads(for: custom, settings: settings) == [5, 0])
        var otherSettings = settings
        otherSettings.trialLeadDays = 3
        otherSettings.yearLeadDays = 21
        #expect(ReminderRules.leads(for: TestSupport.trial(end: "2026-10-20"), settings: otherSettings) == [3, 0])
        #expect(ReminderRules.leads(for: TestSupport.subscription(anchor: "2027-01-01", interval: .year), settings: otherSettings) == [21, 2])
    }

    @Test func noRemindersWhenCancelledOrStopped() {
        var item = TestSupport.trial(end: "2026-10-20")
        item.status = .cancelled
        #expect(ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).isEmpty)
        item.status = .stopped
        #expect(ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).isEmpty)
    }

    @Test func remindersOnSameDayMerge() {
        var item = TestSupport.trial(end: "2026-10-20")
        item.leadDaysOverride = 0
        let reminders = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar)
        #expect(reminders.count == 1)
        #expect(reminders.first?.isTimeSensitive == true)
    }

    @Test func pastReminderBeforeTimeShiftsToToday() {
        // Lead 14 falls before today; at 08:00 today's 09:00 is still ahead.
        let item = TestSupport.subscription(anchor: "2026-10-12", interval: .year)
        let days = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).map(\.day)
        #expect(days == [TestSupport.day("2026-10-04"), TestSupport.day("2026-10-10")])
    }

    @Test func customTime() {
        var custom = settings
        custom.hour = 19
        custom.minute = 30
        let item = TestSupport.trial(end: "2026-10-04")
        // The decision is today and 19:30 has not passed yet at 08:00.
        let reminders = ReminderRules.reminders(for: item, settings: custom, today: today, now: now, calendar: calendar)
        #expect(reminders.map(\.fireDate) == [TestSupport.moment("2026-10-04", 19, 30)])
        #expect(reminders.first?.isTimeSensitive == true)
    }

    @Test func groups() {
        let items = [
            TestSupport.trial("Binnen een week", end: "2026-10-09"),
            TestSupport.trial("Binnen een maand", end: "2026-10-30"),
            TestSupport.trial("Later", end: "2026-12-30"),
            TestSupport.subscription("Maand zonder seintjes", anchor: "2026-10-06", interval: .month),
            { var i = TestSupport.trial("Opgezegd", end: "2026-10-20"); i.status = .cancelled; i.usableUntil = TestSupport.day("2026-10-20"); return i }(),
            { var i = TestSupport.trial("Gestopt", end: "2026-09-20"); i.status = .stopped; i.usableUntil = TestSupport.day("2026-09-20"); return i }(),
            TestSupport.trial("Eerder", end: "2026-10-05"),
        ]
        let grouped = OverviewRules.grouped(items, today: today, now: now, calendar: calendar)
        #expect(grouped.map(\.group) == [.decideNow, .soon, .ongoing, .cancelled, .stopped])
        #expect(grouped[0].items.map(\.name) == ["Eerder", "Binnen een week"])
        #expect(grouped[1].items.map(\.name) == ["Binnen een maand"])
        #expect(grouped[2].items.map(\.name) == ["Maand zonder seintjes", "Later"])
        #expect(OverviewRules.decideNowCount(items, today: today, now: now, calendar: calendar) == 2)
        #expect(OverviewRules.nextUp(items, today: today, now: now, calendar: calendar)?.name == "Eerder")
    }

    @Test func badgePerDay() {
        let items = [TestSupport.trial("A", end: "2026-10-20"), TestSupport.trial("B", end: "2026-10-30")]
        let planned = NotificationPlanner.plan(items: items, settings: settings, today: today, now: now, calendar: calendar)
        // On 2026-10-18 only A is within 7 days; on 2026-10-28 B is (A has expired).
        #expect(planned.first { $0.day == TestSupport.day("2026-10-18") }?.badge == 1)
        #expect(planned.first { $0.day == TestSupport.day("2026-10-28") }?.badge == 1)
        var noBadge = settings
        noBadge.badgeEnabled = false
        #expect(NotificationPlanner.plan(items: items, settings: noBadge, today: today, now: now, calendar: calendar).allSatisfy { $0.badge == nil })
    }

    @Test func passedFixedEndContinuesMonthly() {
        var item = TestSupport.subscription(anchor: "2026-10-01", interval: .fixedEnd, price: 2500)
        Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar)
        #expect(item.interval == .month)
        #expect(item.anchor == TestSupport.day("2026-10-01"))
        #expect(item.needsConfirmation)
        #expect(DecisionRules.relevantDate(for: item, today: today, now: now, calendar: calendar) == TestSupport.day("2026-11-01"))
    }

    @Test func oldSnoozeIsCleared() {
        var item = TestSupport.trial(end: "2026-10-20")
        item.snoozeDay = TestSupport.day("2026-10-03")
        #expect(Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar))
        #expect(item.snoozeDay == nil)
    }

    @Test func weeklyRenewal() {
        let item = TestSupport.subscription(anchor: "2026-09-01", interval: .week)
        #expect(DecisionRules.relevantDate(for: item, today: today, now: now, calendar: calendar) == TestSupport.day("2026-10-06"))
    }

    @Test func longNoticeSkipsSeveralRounds() throws {
        let item = TestSupport.subscription(anchor: "2026-10-10", interval: .month, notice: 2, unit: .months)
        let decision = try #require(DecisionRules.decision(for: item, today: today, now: now, calendar: calendar))
        #expect(decision.isTooLateThisRound)
        #expect(decision.relevantDate == TestSupport.day("2026-12-10"))
        #expect(decision.decisionDate == TestSupport.day("2026-10-10"))
    }

    @Test func cancelAndUndo() {
        var item = TestSupport.trial(end: "2026-10-20")
        let until = ItemActions.defaultUsableUntil(for: item, today: today, now: now, calendar: calendar)
        #expect(until == TestSupport.day("2026-10-20"))
        ItemActions.markCancelled(&item, usableUntil: until, now: now)
        #expect(item.status == .cancelled)
        #expect(OverviewRules.group(for: item, today: today, now: now, calendar: calendar) == .cancelled)
        ItemActions.undoCancel(&item, today: today, now: now)
        #expect(item.status == .trial)
        #expect(item.usableUntil == nil)
    }

    @Test func confirmationCard() {
        var item = TestSupport.trial(end: "2026-10-01")
        Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar)
        var kept = item
        ItemActions.confirmContinues(&kept, now: now)
        #expect(!kept.needsConfirmation)
        #expect(kept.status == .active)
        ItemActions.alreadyCancelled(&item, today: today, now: now)
        #expect(item.status == .stopped)
        #expect(!item.needsConfirmation)
        #expect(item.usableUntil == TestSupport.day("2026-10-01"))
    }
}

@Suite("Formulier")
struct DraftTests {
    let calendar = TestSupport.calendar
    let settings = TestSupport.settings
    let today = TestSupport.day("2026-10-04")
    let now = TestSupport.moment("2026-10-04", 12)

    private func service(kind: Kind = .trial, interval: BillingInterval? = .month, trialDays: Int? = nil) -> CatalogService {
        CatalogService(id: "videoland", name: "Videoland", aliases: [], category: .streaming, defaultKind: kind,
                       defaultInterval: interval, trialDays: trialDays, cancelURL: nil, domains: [], appleBilling: false, popular: true)
    }

    @Test func defaultsFromCatalog() {
        let draft = ItemDraft(name: "video", service: service(trialDays: 14), today: today)
        #expect(draft.name == "Videoland")
        #expect(draft.catalogID == "videoland")
        #expect(draft.trialLength == .days(14))
        #expect(draft.trialEnd == TestSupport.day("2026-10-18"))

        let odd = ItemDraft(name: "", service: service(trialDays: 31), today: today)
        #expect(odd.trialLength == .date)
        #expect(odd.trialEnd == TestSupport.day("2026-11-04"))

        let subscription = ItemDraft(name: "", service: service(kind: .subscription, interval: .year), today: today)
        #expect(subscription.kind == .subscription)
        #expect(subscription.renewalDate == TestSupport.day("2027-10-04"))
    }

    @Test func liveLine() {
        let draft = ItemDraft(name: "Videoland", service: nil, today: today)
        #expect(draft.liveLine(settings: settings, today: today, now: now, calendar: calendar) == "Eindigt di 3 nov · seintje zo 1 nov")

        var tooLate = ItemDraft(name: "NRC", service: service(kind: .subscription, interval: .year), today: today)
        tooLate.renewalDate = TestSupport.day("2026-10-10")
        tooLate.noticeValue = 1
        tooLate.noticeUnit = .months
        #expect(tooLate.liveLine(settings: settings, today: today, now: now, calendar: calendar) == "Te laat voor deze ronde. Volgende kans: vr 10 sep 2027.")
    }

    @Test func pastDateBecomesActiveSubscription() {
        var draft = ItemDraft(name: "Videoland", service: nil, today: today)
        draft.trialLength = .date
        draft.trialEnd = TestSupport.day("2026-09-20")
        #expect(draft.isInPast(today: today))
        #expect(draft.liveLine(settings: settings, today: today, now: now, calendar: calendar) == "Deze datum is voorbij; waarschijnlijk loopt het al door.")
        let item = draft.build(today: today, now: now, calendar: calendar)
        #expect(item.status == .active)
        #expect(item.kind == .subscription)
        #expect(item.anchor == TestSupport.day("2026-09-20"))
        #expect(item.interval == .month)
    }

    @Test func editKeepsAnchorOn31st() {
        let item = TestSupport.subscription(anchor: "2026-01-31", interval: .month, price: 999)
        var draft = ItemDraft(item: item, today: today, now: now, calendar: calendar)
        #expect(draft.renewalDate == TestSupport.day("2026-10-31"))
        #expect(draft.priceText == "9,99")
        draft.note = "Gedeeld met huisgenoot"
        let saved = draft.build(today: today, now: now, calendar: calendar)
        #expect(saved.id == item.id)
        #expect(saved.anchor == TestSupport.day("2026-01-31"))
        #expect(saved.note == "Gedeeld met huisgenoot")
    }

    @Test func intervalChangeMovesDefaultDate() {
        var draft = ItemDraft(name: "", service: service(kind: .subscription, interval: .month), today: today)
        #expect(draft.renewalDate == TestSupport.day("2026-11-04"))
        draft.selectInterval(.year, today: today)
        #expect(draft.renewalDate == TestSupport.day("2027-10-04"))
    }

    @Test func emptyNameGetsPlaceholder() {
        var draft = ItemDraft(name: "  ", service: nil, today: today)
        draft.name = "  "
        #expect(draft.build(today: today, now: now, calendar: calendar).name == "Naamloos")
    }
}

@Suite("Eerste toevoeging")
struct AddedMessageTests {
    let calendar = TestSupport.calendar
    let settings = TestSupport.settings
    let today = TestSupport.day("2026-10-04")
    let now = TestSupport.moment("2026-10-04", 12)

    @Test func toastNamesFirstReminder() {
        // Trial ending 2026-10-31: first reminder two days before.
        let trial = TestSupport.trial(end: "2026-10-31")
        #expect(ReminderRules.addedMessage(for: trial, settings: settings, today: today, now: now, calendar: calendar)
            == "Toegevoegd · seintje do 29 okt")

        // Decision in two days: lead 2 falls today at 09:00, which has passed, so tomorrow.
        let soon = TestSupport.trial(end: "2026-10-06")
        #expect(ReminderRules.addedMessage(for: soon, settings: settings, today: today, now: now, calendar: calendar)
            == "Toegevoegd · seintje morgen")

        let early = TestSupport.trial(end: "2026-10-06")
        #expect(ReminderRules.addedMessage(for: early, settings: settings, today: today, now: TestSupport.moment("2026-10-04", 8), calendar: calendar)
            == "Toegevoegd · seintje vandaag")
    }

    @Test func toastWithoutReminder() {
        let monthly = TestSupport.subscription(anchor: "2026-11-01", interval: .month)
        #expect(ReminderRules.addedMessage(for: monthly, settings: settings, today: today, now: now, calendar: calendar) == "Toegevoegd")
    }
}

@Suite("CSV")
struct CSVTests {
    @Test func export() {
        var item = TestSupport.trial("Krant; zaterdag", end: "2026-10-20", price: 999)
        item.note = "Zei \"misschien\""
        let csv = CSVExport.make([item])
        #expect(csv.hasPrefix("\u{FEFF}id;naam;"))
        let lines = csv.dropFirst().components(separatedBy: "\r\n").filter { !$0.isEmpty }
        #expect(lines.count == 2)
        #expect(lines[1].contains("\"Krant; zaterdag\""))
        #expect(lines[1].contains(";9,99;"))
        #expect(lines[1].contains("\"Zei \"\"misschien\"\"\""))
        #expect(CSVExport.header.count == 22)
        #expect(CSVExport.fileName(today: TestSupport.day("2026-10-04")) == "opzegwekker-2026-10-04.csv")
    }
}
