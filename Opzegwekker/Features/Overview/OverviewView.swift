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
            .background(Color.paper)
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
                totalRow(total)
                    .listRowBackground(Color.paper)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20))
            }

            cards(data)

            ForEach(groups) { entry in
                Section {
                    if isExpanded(entry.group) {
                        ForEach(entry.items) { item in
                            row(for: item, today: today, now: now)
                                .listRowBackground(Color.paper)
                                .listRowSeparatorTint(Color.hairline)
                                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 16))
                        }
                        if entry.group == .stopped, !stoppedTotal.isEmpty {
                            Text(stoppedTotal.stoppedText)
                                .font(.serif(.subheadline).italic())
                                .foregroundStyle(.secondary)
                                .listRowBackground(Color.paper)
                                .listRowSeparator(.hidden)
                        }
                    }
                } header: {
                    header(for: entry.group, count: entry.items.count)
                }
            }
        }
        .listStyle(.plain)
        .paperBackground()
        .animation(.default, value: expandedGroups)
    }

    // MARK: - Pieces

    private func totalRow(_ total: MonthlyTotal) -> some View {
        Button {
            withAnimation { showsTotalExplanation.toggle() }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text("± \(DutchFormat.euroRounded(cents: total.cents)) \(Text("per maand").font(.subheadline).foregroundStyle(.secondary))")
                    .font(.serif(.largeTitle))
                    .foregroundStyle(Color.ink)
                    .monospacedDigit()
                    .accessibilityLabel(total.activeText)
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
        headerContent(for: group, count: count)
            .padding(.horizontal, 4)
            .padding(.top, 14)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.paper)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    @ViewBuilder
    private func headerContent(for group: OverviewGroup, count: Int) -> some View {
        if group.isCollapsedByDefault {
            Button {
                if expandedGroups.contains(group) {
                    expandedGroups.remove(group)
                } else {
                    expandedGroups.insert(group)
                }
            } label: {
                HStack {
                    GroupLabel(title: group.title, count: count)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded(group) ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityValue(isExpanded(group) ? "uitgeklapt" : "ingeklapt")
        } else {
            GroupLabel(title: group.title, count: count)
                .accessibilityAddTraits(.isHeader)
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
                    model.beginMarkCancelled(item.id)
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
        .accessibilityActions {
            if item.isLive {
                Button("Opgezegd") { model.beginMarkCancelled(item.id) }
            }
            Button("Verwijder") { model.delete(item.id) }
        }
    }

    @ViewBuilder
    private func cards(_ data: [ItemData]) -> some View {
        let showsDenied = model.notificationStatus == .denied && !model.settings.deniedCardDismissed
        let unconfirmed = data.filter { $0.needsConfirmation && $0.status == .active }
        if showsDenied || !unconfirmed.isEmpty {
            Group {
                if showsDenied {
                    NotificationsDeniedCard {
                        model.openNotificationSettings()
                    } onDismiss: {
                        withAnimation { model.settings.deniedCardDismissed = true }
                    }
                }
                ForEach(unconfirmed) { item in
                    ConfirmationCard(name: item.name) {
                        withAnimation { model.confirmContinues(item.id) }
                    } onAlreadyCancelled: {
                        withAnimation { model.alreadyCancelled(item.id) }
                    }
                }
            }
            .listRowBackground(Color.paper)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
    }
}

/// The add button in the thumb zone, on a fade of the page so the list ends softly.
struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Voeg toe", systemImage: "plus")
                .labelStyle(.titleAndIcon)
                .font(.headline)
                .foregroundStyle(Color.paper)
                .padding(.horizontal, 28)
                .frame(minHeight: 52)
                .background(Color.ink, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: [Color.paper.opacity(0), Color.paper], startPoint: .top, endPoint: .center)
                .allowsHitTesting(false)
        )
    }
}
