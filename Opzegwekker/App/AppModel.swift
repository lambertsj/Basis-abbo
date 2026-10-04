import Foundation
import Observation
import OSLog
import SwiftData
import SwiftUI
import UserNotifications

/// App-wide state and the actions that change items.
///
/// Views read items live through `@Query`; every change goes through this model so the
/// follow-up work (saving, rescheduling notifications, reloading the widget) is never
/// forgotten.
@MainActor
@Observable
final class AppModel {
    enum Route: Hashable {
        case item(UUID)
    }

    enum AddStart: Hashable {
        case search
        case service(String)
    }

    enum Sheet: Identifiable, Hashable {
        case settings
        case add(AddStart)

        var id: Self { self }
    }

    struct Toast: Identifiable {
        let id = UUID()
        var message: String
        var undo: (() -> Void)?
    }

    let container: ModelContainer
    let catalog: Catalog
    private let logger = Logger(subsystem: "Opzegwekker", category: "model")
    let settings: SettingsStore

    var path: [Route] = []
    var sheet: Sheet?
    var toast: Toast?
    /// The current day; refreshed at start and whenever the app becomes active.
    private(set) var today: CalendarDay
    var notificationStatus: UNAuthorizationStatus = .notDetermined
    /// Incremented to trigger haptics from the root view.
    var successHaptic = 0
    var lightHaptic = 0

    @ObservationIgnored private var toastTask: Task<Void, Never>?

    init(container: ModelContainer, catalog: Catalog = .bundled, settings: SettingsStore = SettingsStore()) {
        self.container = container
        self.catalog = catalog
        self.settings = settings
        today = CalendarDay(Date(), calendar: .current)
    }

    var context: ModelContext { container.mainContext }
    var calendar: Calendar { .current }
    var now: Date { Date() }

    // MARK: - Lifecycle

    func start() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-OpzegwekkerSeed") {
            DebugSeed.populate(context: context, today: today, catalog: catalog)
        }
        #endif
        await refresh()
    }

    /// Runs the transitions, saves and updates everything derived from the items.
    func refresh() async {
        today = CalendarDay(now, calendar: calendar)
        runTransitions()
        await updateNotificationStatus()
        afterChange()
    }

    func updateNotificationStatus() async {
        notificationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Fetching

    func allItems() -> [Item] {
        (try? context.fetch(FetchDescriptor<Item>())) ?? []
    }

    func item(_ id: UUID) -> Item? {
        let target = id
        var descriptor = FetchDescriptor<Item>(predicate: #Predicate { $0.id == target })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    // MARK: - Changes

    private func runTransitions() {
        let intervals = catalog.defaultIntervals
        for item in allItems() {
            var data = item.data
            let interval = data.catalogID.flatMap { intervals[$0] }
            if Transitions.apply(to: &data, defaultInterval: interval, today: today, now: now, calendar: calendar) {
                item.apply(data)
            }
        }
    }

    /// Saves and updates everything that depends on the items.
    func afterChange() {
        do {
            try context.save()
        } catch {
            logger.error("Saving failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Applies a pure domain change to one item.
    func mutate(_ id: UUID, _ change: (inout ItemData) -> Void) {
        guard let item = item(id) else { return }
        var data = item.data
        change(&data)
        item.apply(data)
        afterChange()
    }

    /// Saves a new or edited item. Returns its id.
    @discardableResult
    func save(_ draft: ItemDraft) -> UUID {
        let data = draft.build(today: today, now: now, calendar: calendar)
        if let existing = item(data.id) {
            existing.apply(data)
            afterChange()
            return data.id
        }

        let isFirst = allItems().isEmpty
        context.insert(Item(data: data))
        settings.deniedCardDismissed = false
        afterChange()
        successHaptic += 1
        showToast("Toegevoegd") { [weak self] in
            self?.delete(data.id, showUndo: false)
        }
        if isFirst {
            Task { await requestAuthorizationIfNeeded() }
        }
        return data.id
    }

    /// Deletes an item at once and offers to undo it from a full snapshot.
    func delete(_ id: UUID, showUndo: Bool = true) {
        guard let item = item(id) else { return }
        let snapshot = item.data
        context.delete(item)
        path.removeAll { $0 == .item(id) }
        afterChange()
        guard showUndo else { return }
        showToast("Verwijderd") { [weak self] in
            self?.restore(snapshot)
        }
    }

    func restore(_ snapshot: ItemData) {
        guard item(snapshot.id) == nil else { return }
        context.insert(Item(data: snapshot))
        afterChange()
    }

    // MARK: - Notifications permission

    /// Asks for permission half a second after the first item is saved, without an
    /// explanation screen first.
    func requestAuthorizationIfNeeded() async {
        await updateNotificationStatus()
        guard notificationStatus == .notDetermined else { return }
        try? await Task.sleep(nanoseconds: 500_000_000)
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        await updateNotificationStatus()
        afterChange()
    }

    // MARK: - Toast

    func showToast(_ message: String, undo: (() -> Void)? = nil) {
        toastTask?.cancel()
        let toast = Toast(message: message, undo: undo)
        withAnimation { self.toast = toast }
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            guard !Task.isCancelled, let self, self.toast?.id == toast.id else { return }
            withAnimation { self.toast = nil }
        }
    }

    func performToastUndo() {
        guard let undo = toast?.undo else { return }
        toastTask?.cancel()
        withAnimation { toast = nil }
        undo()
    }
}
