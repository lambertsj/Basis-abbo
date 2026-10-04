import SwiftData
import SwiftUI
import WidgetKit

/// What the small widget shows for one day.
struct DecisionEntry: TimelineEntry {
    struct Summary {
        var id: UUID
        var name: String
        var category: ServiceCategory
        var daysLeft: Int
        var daysLeftText: String
        var urgency: Urgency
        var accessibilityLabel: String
    }

    let date: Date
    let item: Summary?
}

struct DecisionProvider: TimelineProvider {
    func placeholder(in context: Context) -> DecisionEntry {
        DecisionEntry(
            date: Date(),
            item: DecisionEntry.Summary(
                id: UUID(),
                name: "Videoland",
                category: .streaming,
                daysLeft: 3,
                daysLeftText: "nog 3 dagen",
                urgency: .medium,
                accessibilityLabel: "Videoland, nog 3 dagen"
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DecisionEntry) -> Void) {
        if context.isPreview {
            completion(placeholder(in: context))
        } else {
            completion(makeEntries(days: 1).first ?? DecisionEntry(date: Date(), item: nil))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DecisionEntry>) -> Void) {
        completion(Timeline(entries: makeEntries(days: 7), policy: .atEnd))
    }

    /// One entry now and one at 00:00 for each following day.
    private func makeEntries(days: Int) -> [DecisionEntry] {
        let calendar = Calendar.current
        let now = Date()
        let items = loadItems()
        let catalog = Catalog.bundled
        let intervals = catalog.defaultIntervals
        let startOfToday = calendar.startOfDay(for: now)

        return (0..<days).compactMap { offset in
            let date = offset == 0 ? now : calendar.date(byAdding: .day, value: offset, to: startOfToday)
            guard let date else { return nil }
            let today = CalendarDay(date, calendar: calendar)
            let current = items.map { original -> ItemData in
                var item = original
                Transitions.apply(
                    to: &item,
                    defaultInterval: item.catalogID.flatMap { intervals[$0] },
                    today: today,
                    now: date,
                    calendar: calendar
                )
                return item
            }
            guard let next = OverviewRules.nextUp(current, today: today, now: date, calendar: calendar) else {
                return DecisionEntry(date: date, item: nil)
            }
            let texts = ItemTexts(item: next, today: today, now: date, calendar: calendar)
            return DecisionEntry(
                date: date,
                item: DecisionEntry.Summary(
                    id: next.id,
                    name: next.name,
                    category: catalog.category(for: next.catalogID),
                    daysLeft: texts.daysLeft ?? 0,
                    daysLeftText: texts.daysLeftText ?? "",
                    urgency: texts.urgency,
                    accessibilityLabel: texts.accessibilityLabel
                )
            )
        }
    }

    private func loadItems() -> [ItemData] {
        guard let container = try? Store.makeContainer() else { return [] }
        let context = ModelContext(container)
        return ((try? context.fetch(FetchDescriptor<Item>())) ?? []).map(\.data)
    }
}

struct DecisionWidgetView: View {
    let entry: DecisionEntry

    var body: some View {
        Group {
            if let item = entry.item {
                VStack(alignment: .leading, spacing: 4) {
                    LetterIcon(name: item.name, category: item.category, size: 36)
                    Spacer(minLength: 4)
                    Text(item.name)
                        .font(.serif(.headline, weight: .semibold))
                        .foregroundStyle(Color.ink)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                    DaysLeftLabel(days: item.daysLeft, text: item.daysLeftText, urgency: item.urgency)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(item.accessibilityLabel)
                .widgetURL(URL(string: "opzegwekker://item/\(item.id.uuidString)"))
            } else {
                Text("Niets om over te beslissen")
                    .font(.serif(.body))
                    .foregroundStyle(Color.ink.opacity(0.7))
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .widgetURL(URL(string: "opzegwekker://overview"))
            }
        }
        .containerBackground(Color.paper, for: .widget)
    }
}

@main
struct DecisionWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DecisionWidget", provider: DecisionProvider()) { entry in
            DecisionWidgetView(entry: entry)
        }
        .configurationDisplayName("Opzegwekker")
        .description("Je eerstvolgende beslissing.")
        .supportedFamilies([.systemSmall])
    }
}
