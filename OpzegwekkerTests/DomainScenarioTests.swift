import Foundation
import Testing
#if SWIFT_PACKAGE
@testable import OpzegwekkerCore
#else
@testable import Opzegwekker
#endif

/// The required cases from the brief, §9.
@Suite("Domeinscenario's")
struct DomainScenarioTests {
    let calendar = TestSupport.calendar
    let settings = TestSupport.settings

    // 1
    @Test("Proef van 30 dagen")
    func trialOf30Days() throws {
        let today = TestSupport.day("2026-10-01")
        let now = TestSupport.moment("2026-10-01", 12)
        let draft = ItemDraft(name: "Videoland", service: nil, today: today)
        let item = draft.build(today: today, now: now, calendar: calendar)

        #expect(item.status == .trial)
        #expect(item.trialEnd == TestSupport.day("2026-10-31"))
        let decision = try #require(DecisionRules.decision(for: item, today: today, now: now, calendar: calendar))
        #expect(decision.relevantDate == TestSupport.day("2026-10-31"))
        #expect(decision.decisionDate == TestSupport.day("2026-10-31"))

        let reminders = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar)
        #expect(reminders.map(\.day) == [TestSupport.day("2026-10-29"), TestSupport.day("2026-10-31")])
        #expect(reminders.map(\.fireDate) == [TestSupport.moment("2026-10-29", 9), TestSupport.moment("2026-10-31", 9)])
        #expect(reminders.map(\.isTimeSensitive) == [false, true])

        let planned = NotificationPlanner.plan(items: [item], settings: settings, today: today, now: now, calendar: calendar)
        #expect(planned.count == 2)
        #expect(planned.map(\.isTimeSensitive) == [false, true])
        #expect(planned[0].identifier == "item-\(item.id.uuidString)-2026-10-29")
        #expect(planned[0].dateComponents == DateComponents(year: 2026, month: 10, day: 29, hour: 9, minute: 0))
    }

    // 2
    @Test("Jaarabonnement met opzegtermijn")
    func yearlyWithNoticePeriod() throws {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let item = TestSupport.subscription(anchor: "2026-11-14", interval: .year, notice: 1, unit: .months)

        let decision = try #require(DecisionRules.decision(for: item, today: today, now: now, calendar: calendar))
        #expect(decision.relevantDate == TestSupport.day("2026-11-14"))
        #expect(decision.decisionDate == TestSupport.day("2026-10-14"))
        #expect(!decision.isTooLateThisRound)

        let reminders = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar)
        // The 2026-09-30 reminder (14 days before) is past and moves to the next 09:00.
        #expect(reminders.map(\.day) == [TestSupport.day("2026-10-05"), TestSupport.day("2026-10-12")])
        #expect(reminders.first?.fireDate == TestSupport.moment("2026-10-05", 9))
        #expect(reminders.allSatisfy { !$0.isTimeSensitive })
    }

    // 3
    @Test("Maandanker op de 31e")
    func monthlyAnchorOn31st() throws {
        let item = TestSupport.subscription(anchor: "2027-01-31", interval: .month)
        let now = TestSupport.moment("2027-02-01", 12)

        let february = try #require(DecisionRules.relevantDate(for: item, today: TestSupport.day("2027-02-01"), now: now, calendar: calendar))
        #expect(february == TestSupport.day("2027-02-28"))
        let march = try #require(DecisionRules.relevantDate(for: item, today: TestSupport.day("2027-03-01"), now: now, calendar: calendar))
        #expect(march == TestSupport.day("2027-03-31"))

        let anchor = TestSupport.day("2027-01-31")
        #expect(DecisionRules.renewal(anchor: anchor, interval: .month, index: 1) == TestSupport.day("2027-02-28"))
        #expect(DecisionRules.renewal(anchor: anchor, interval: .month, index: 2) == TestSupport.day("2027-03-31"))
    }

    // 4
    @Test("Te laat voor deze ronde")
    func tooLateThisRound() throws {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let item = TestSupport.subscription(anchor: "2026-10-10", interval: .year, notice: 1, unit: .months)

        let decision = try #require(DecisionRules.decision(for: item, today: today, now: now, calendar: calendar))
        #expect(decision.isTooLateThisRound)
        #expect(decision.nextDate == TestSupport.day("2026-10-10"))
        #expect(decision.relevantDate == TestSupport.day("2027-10-10"))
        #expect(decision.decisionDate == TestSupport.day("2027-09-10"))

        let texts = DetailTexts(item: item, today: today, now: now, calendar: calendar)
        #expect(texts.tooLateNote == "Te laat voor deze ronde. Volgende kans: vr 10 sep 2027.")
    }

    // 5
    @Test("Beslisdatum vandaag, tijdstip voorbij")
    func decisionTodayTimePassed() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let item = TestSupport.trial(end: "2026-10-04")

        #expect(ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).isEmpty)
        #expect(NotificationPlanner.plan(items: [item], settings: settings, today: today, now: now, calendar: calendar).isEmpty)
        #expect(OverviewRules.group(for: item, today: today, now: now, calendar: calendar) == .decideNow)
        let texts = ItemTexts(item: item, today: today, now: now, calendar: calendar)
        #expect(texts.daysLeftText == "vandaag")
        #expect(texts.urgency == .high)
    }

    // 6
    @Test("Bundelen")
    func bundling() throws {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let videoland = TestSupport.trial("Videoland", end: "2026-10-20")
        let nrc = TestSupport.trial("NRC", end: "2026-10-20")

        let planned = NotificationPlanner.plan(items: [videoland, nrc], settings: settings, today: today, now: now, calendar: calendar)
        // Two days (18th and 20th), each bundled into one request.
        #expect(planned.count == 2)
        let first = try #require(planned.first)
        #expect(first.identifier == "day-2026-10-18")
        #expect(first.category == .bundle)
        #expect(first.title == "Vandaag 2 beslissingen")
        #expect(first.body == "NRC en Videoland")
        #expect(Set(first.itemIDs) == [videoland.id, nrc.id])
        #expect(!first.isTimeSensitive)
        #expect(planned[1].isTimeSensitive)
    }

    @Test("Bundelen met meer dan 3 items")
    func bundlingMany() throws {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let items = ["Videoland", "NRC", "Spotify", "Storytel"].enumerated().map { index, name in
            var item = TestSupport.trial(name, end: "2026-10-20")
            item.createdAt = TestSupport.moment("2026-01-0\(index + 1)", 12)
            return item
        }
        let planned = NotificationPlanner.plan(items: items, settings: settings, today: today, now: now, calendar: calendar)
        let first = try #require(planned.first)
        #expect(first.title == "Vandaag 4 beslissingen")
        #expect(first.body == "NRC, Spotify en 2 andere")
    }

    // 7
    @Test("Limiet van 50 meldingen")
    func limit() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        // 80 trials ending on different days, two reminders each, none shared.
        let items = (0..<80).map { index in
            TestSupport.trial("Dienst \(index)", end: today.adding(days: 10 + 3 * index).isoString)
        }
        let all = NotificationPlanner.plan(items: items, settings: settings, limit: .max, today: today, now: now, calendar: calendar)
        let planned = NotificationPlanner.plan(items: items, settings: settings, today: today, now: now, calendar: calendar)

        #expect(all.count == 160)
        #expect(planned.count == 50)
        #expect(planned == Array(all.prefix(50)))
        #expect(planned.map(\.fireDate) == planned.map(\.fireDate).sorted())
    }

    // 8
    @Test("Morgen opnieuw op de laatste dag")
    func snoozeOnLastDay() throws {
        let today = TestSupport.day("2026-10-30")
        let now = TestSupport.moment("2026-10-30", 10)
        var item = TestSupport.trial(end: "2026-10-31")

        ItemActions.snooze(&item, today: today, now: now, calendar: calendar)
        #expect(item.snoozeDay == TestSupport.day("2026-10-31"))

        let reminders = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar)
        #expect(reminders.count == 1)
        let reminder = try #require(reminders.first)
        #expect(reminder.day == TestSupport.day("2026-10-31"))
        #expect(reminder.isTimeSensitive)

        let planned = NotificationPlanner.plan(items: [item], settings: settings, today: today, now: now, calendar: calendar)
        #expect(planned.count == 1)
        #expect(planned.first?.isTimeSensitive == true)
        #expect(planned.first?.body == "Laatste dag om kosteloos op te zeggen.")
    }

    @Test("Morgen opnieuw schuift eerdere seintjes op")
    func snoozeDropsEarlierReminders() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 10)
        var item = TestSupport.subscription(anchor: "2026-10-20", interval: .year)
        // Leads 14 and 2 → 2026-10-06 and 2026-10-18; today's 09:00 has passed.
        ItemActions.snooze(&item, today: today, now: now, calendar: calendar)
        #expect(item.snoozeDay == TestSupport.day("2026-10-05"))
        let days = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).map(\.day)
        #expect(days == [TestSupport.day("2026-10-05"), TestSupport.day("2026-10-06"), TestSupport.day("2026-10-18")])
    }

    // 9
    @Test("Verlopen proef zonder actie")
    func expiredTrialWithoutAction() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        var item = TestSupport.trial(end: "2026-10-01")

        let changed = Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar)
        #expect(changed)
        #expect(item.status == .active)
        #expect(item.kind == .subscription)
        #expect(item.interval == .month)
        #expect(item.anchor == TestSupport.day("2026-10-01"))
        #expect(item.needsConfirmation)
        #expect(ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).isEmpty)

        // Idempotent.
        let again = item
        #expect(!Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar))
        #expect(item == again)
    }

    @Test("Verlopen proef neemt het catalogusinterval over")
    func expiredTrialUsesCatalogInterval() {
        var item = TestSupport.trial(end: "2026-10-01")
        Transitions.apply(to: &item, defaultInterval: .year, today: TestSupport.day("2026-10-04"), now: TestSupport.moment("2026-10-04", 12), calendar: calendar)
        #expect(item.interval == .year)
    }

    // 10
    @Test("Afgelopen opzegging")
    func endedCancellation() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        var item = TestSupport.subscription(anchor: "2026-10-03", interval: .month, status: .cancelled)
        item.usableUntil = TestSupport.day("2026-10-03")

        #expect(Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar))
        #expect(item.status == .stopped)
        #expect(!Transitions.apply(to: &item, defaultInterval: nil, today: today, now: now, calendar: calendar))
    }

    // 11
    @Test("Zomertijd: na de overgang naar wintertijd blijft het 09:00")
    func daylightSaving() throws {
        let today = TestSupport.day("2026-10-20")
        let now = TestSupport.moment("2026-10-20", 12)
        let item = TestSupport.trial(end: "2026-10-26")

        let reminders = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar)
        let last = try #require(reminders.last)
        #expect(last.day == TestSupport.day("2026-10-26"))
        // 2026-10-26 is CET (UTC+1): 09:00 Amsterdam = 08:00 UTC.
        #expect(last.fireDate == TestSupport.utc("2026-10-26T08:00:00Z"))
        // 2026-10-24 is still CEST (UTC+2).
        #expect(reminders.first?.fireDate == TestSupport.utc("2026-10-24T07:00:00Z"))

        let planned = NotificationPlanner.plan(items: [item], settings: settings, today: today, now: now, calendar: calendar)
        #expect(planned.last?.dateComponents == DateComponents(year: 2026, month: 10, day: 26, hour: 9, minute: 0))
        #expect(planned.last?.dateComponents.timeZone == nil)
    }

    // 12
    @Test("Maandtotaal")
    func monthlyTotal() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        let items = [
            TestSupport.subscription("Jaar", anchor: "2027-01-01", interval: .year, price: 12_000),
            TestSupport.subscription("Maand", anchor: "2026-11-01", interval: .month, price: 999),
            TestSupport.subscription("Week", anchor: "2026-10-10", interval: .week, price: 300),
            TestSupport.subscription("Zonder prijs", anchor: "2026-10-10", interval: .month),
            TestSupport.trial("Proef", end: "2026-10-20", price: 999),
        ]
        let total = MonthlyTotal.compute(items, status: .active, today: today, now: now, calendar: calendar)
        #expect(abs(total.cents - 3299) < 0.0001)
        #expect(total.activeText == "± € 33 per maand")
        #expect(total.pricedCount == 3)
        #expect(total.totalCount == 4)
        #expect(total.explanation == "Berekend op basis van 3 van 4 abonnementen.")

        let none = MonthlyTotal.compute([items[3]], status: .active, today: today, now: now, calendar: calendar)
        #expect(none.isEmpty)
    }

    // 13
    @Test("Houden op een proef")
    func keepOnTrial() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        var item = TestSupport.trial(end: "2026-10-10")

        let message = ItemActions.keep(&item, today: today, now: now, calendar: calendar)
        #expect(message == "Geen seintjes meer voor deze proef")
        #expect(item.decidedThrough == TestSupport.day("2026-10-10"))
        #expect(ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).isEmpty)
        #expect(OverviewRules.group(for: item, today: today, now: now, calendar: calendar) == .ongoing)

        let later = TestSupport.day("2026-10-11")
        Transitions.apply(to: &item, defaultInterval: nil, today: later, now: TestSupport.moment("2026-10-11", 12), calendar: calendar)
        #expect(item.status == .active)
        #expect(!item.needsConfirmation)
    }

    @Test("Houden op een jaarabonnement")
    func keepOnYearly() {
        let today = TestSupport.day("2026-10-04")
        let now = TestSupport.moment("2026-10-04", 12)
        var item = TestSupport.subscription(anchor: "2026-10-20", interval: .year)

        let message = ItemActions.keep(&item, today: today, now: now, calendar: calendar)
        #expect(item.decidedThrough == TestSupport.day("2026-10-20"))
        #expect(message == "Je krijgt weer een seintje vóór wo 20 okt 2027")
        // Reminders move to the next year's decision.
        let days = ReminderRules.reminders(for: item, settings: settings, today: today, now: now, calendar: calendar).map(\.day)
        #expect(days == [TestSupport.day("2027-10-06"), TestSupport.day("2027-10-18")])
        #expect(OverviewRules.group(for: item, today: today, now: now, calendar: calendar) == .ongoing)
    }
}
