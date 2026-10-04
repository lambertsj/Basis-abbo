import SwiftData
import SwiftUI

/// The only main screen: monthly total, cards and the grouped items.
struct OverviewView: View {
    @Environment(AppModel.self) private var model
    @Query(sort: \Item.createdAt) private var items: [Item]
    @State private var expandedGroups: Set<OverviewGroup> = []
    @State private var showsTotalExplanation = false

    var body: some View {
        content
            .navigationTitle("Opzegwekker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        model.sheet = .settings
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Instellingen")
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if items.isEmpty {
            EmptyStateView()
        } else {
            list
                .safeAreaInset(edge: .bottom) {
                    AddButton { model.sheet = .add(.search) }
                }
        }
    }

    private var list: some View {
        let data = items.map(\.data)
        let today = model.today
        let now = model.now
        let calendar = model.calendar
        let groups = OverviewRules.grouped(data, today: today, now: now, calendar: calendar)
        let total = MonthlyTotal.compute(data, status: .active, today: today, now: now, calendar: calendar)
        let stoppedTotal = MonthlyTotal.compute(data, status: .stopped, today: today, now: now, calendar: calendar)

        return List {
            if !total.isEmpty {
                Section {
                    totalRow(total)
                }
            }

            ForEach(groups) { entry in
                Section {
                    if isExpanded(entry.group) {
                        ForEach(entry.items) { item in
                            row(for: item, today: today, now: now)
                        }
                    }
                } header: {
                    header(for: entry.group, count: entry.items.count)
                } footer: {
                    if entry.group == .stopped, isExpanded(.stopped), !stoppedTotal.isEmpty {
                        Text(stoppedTotal.stoppedText)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: expandedGroups)
    }

    // MARK: - Pieces

    private func totalRow(_ total: MonthlyTotal) -> some View {
        Button {
            withAnimation { showsTotalExplanation.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(total.activeText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                if showsTotalExplanation {
                    Text(total.explanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityHint(showsTotalExplanation ? "" : "Toont waarop het totaal is gebaseerd")
    }

    @ViewBuilder
    private func header(for group: OverviewGroup, count: Int) -> some View {
        if group.isCollapsedByDefault {
            Button {
                if expandedGroups.contains(group) {
                    expandedGroups.remove(group)
                } else {
                    expandedGroups.insert(group)
                }
            } label: {
                HStack {
                    Text("\(group.title) (\(count))")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded(group) ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isExpanded(group) ? "uitgeklapt" : "ingeklapt")
        } else {
            Text(group.title)
        }
    }

    private func isExpanded(_ group: OverviewGroup) -> Bool {
        !group.isCollapsedByDefault || expandedGroups.contains(group)
    }

    private func row(for item: ItemData, today: CalendarDay, now: Date) -> some View {
        NavigationLink(value: AppModel.Route.item(item.id)) {
            ItemRow(
                item: item,
                category: model.catalog.category(for: item.catalogID),
                texts: ItemTexts(item: item, today: today, now: now, calendar: model.calendar)
            )
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if item.isLive {
                Button {
                    model.lightHaptic += 1
                } label: {
                    Label("Opgezegd", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                model.lightHaptic += 1
                model.delete(item.id)
            } label: {
                Label("Verwijder", systemImage: "trash")
            }
        }
        .accessibilityAction(named: "Verwijder") {
            model.delete(item.id)
        }
    }
}

/// The floating add button in the thumb zone.
struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Voeg toe", systemImage: "plus")
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
        .padding(.bottom, 8)
    }
}
