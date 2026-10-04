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
        /// "Tot wanneer kun je het nog gebruiken?"
        case markCancelled(UUID)
        /// "Is opzeggen van … gelukt?"
        case cancelSucceeded(UUID)

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
    /// Incremented to ask the root view for an App Store review.
    var reviewRequest = 0
    /// A link the root view should open in Safari.
    var urlToOpen: URL?

    @ObservationIgnored private var toastTask: Task<Void, Never>?
    /// Whether the cancel link was opened in this process and the app has not been in
    /// the background since; then returning to the app is not a return from Safari yet.
    @ObservationIgnored private var cancelOpenedAwaitingBackground = false

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

    // MARK: - Item actions

    /// Opgezegd (swipe): asks until when it can still be used.
    func beginMarkCancelled(_ id: UUID) {
        lightHaptic += 1
        sheet = .markCancelled(id)
    }

    func defaultUsableUntil(for id: UUID) -> CalendarDay {
        guard let item = item(id) else { return today }
        return ItemActions.defaultUsableUntil(for: item.data, today: today, now: now, calendar: calendar)
    }

    func markCancelled(_ id: UUID, usableUntil: CalendarDay) {
        mutate(id) { ItemActions.markCancelled(&$0, usableUntil: usableUntil, now: now) }
        successHaptic += 1
        if !settings.hasCancelledBefore {
            settings.hasCancelledBefore = true
            reviewRequest += 1
        }
    }

    /// Houden. Shows briefly when the next reminder comes.
    func keep(_ id: UUID, showMessage: Bool = true) {
        var message = ""
        mutate(id) { message = ItemActions.keep(&$0, today: today, now: now, calendar: calendar) }
        if showMessage, !message.isEmpty {
            showToast(message)
        }
    }

    /// Morgen opnieuw.
    func snooze(_ id: UUID) {
        mutate(id) { ItemActions.snooze(&$0, today: today, now: now, calendar: calendar) }
    }

    /// Toch niet opgezegd.
    func undoCancel(_ id: UUID) {
        mutate(id) { ItemActions.undoCancel(&$0, today: today, now: now) }
    }

    /// Card: "Klopt".
    func confirmContinues(_ id: UUID) {
        mutate(id) { ItemActions.confirmContinues(&$0, now: now) }
    }

    /// Card: "Ik had al opgezegd".
    func alreadyCancelled(_ id: UUID) {
        mutate(id) { ItemActions.alreadyCancelled(&$0, today: today, now: now) }
    }

    // MARK: - Cancelling

    /// The page the Opzeggen button opens: the cancel link, or a search for it.
    func cancelURL(for item: ItemData) -> URL? {
        if let raw = item.cancelURL?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty {
            let withScheme = raw.contains("://") ? raw : "https://\(raw)"
            if let url = URL(string: withScheme) { return url }
        }
        return searchURL(for: item.name)
    }

    func searchURL(for name: String) -> URL? {
        var components = URLComponents(string: "https://duckduckgo.com/")
        components?.queryItems = [URLQueryItem(name: "q", value: "\(name) opzeggen")]
        return components?.url
    }

    /// Opzeggen, from the detail screen or a notification: opens the cancel page and
    /// remembers it, so the app can ask afterwards whether it worked.
    func requestCancel(_ id: UUID) {
        guard let item = item(id), let url = cancelURL(for: item.data) else { return }
        settings.pendingCancel = PendingCancel(itemID: id, openedAt: now)
        cancelOpenedAwaitingBackground = true
        urlToOpen = url
    }

    /// Opens this app's page in the iOS Settings, where notifications can be turned on.
    func openNotificationSettings() {
        urlToOpen = URL(string: UIApplication.openNotificationSettingsURLString)
    }

    /// "Betaald via Apple?"
    func openAppleSubscriptions() {
        urlToOpen = URL(string: "https://apps.apple.com/account/subscriptions")
    }

    func scenePhaseChanged(_ phase: ScenePhase) {
        switch phase {
        case .active:
            askWhetherCancelSucceeded()
            Task { await refresh() }
        case .background:
            cancelOpenedAwaitingBackground = false
        default:
            break
        }
    }

    /// Asks "Is opzeggen van … gelukt?" when returning within 30 minutes of opening a
    /// cancel link. An older one is cleared without asking.
    private func askWhetherCancelSucceeded() {
        guard let pending = settings.pendingCancel, !cancelOpenedAwaitingBackground else { return }
        settings.pendingCancel = nil
        guard now.timeIntervalSince(pending.openedAt) < 30 * 60, let item = item(pending.itemID), item.data.isLive else { return }
        sheet = .cancelSucceeded(pending.itemID)
    }

    /// "Ja, opgezegd": cancelled, usable until the relevant date.
    func confirmCancelSucceeded(_ id: UUID) {
        markCancelled(id, usableUntil: defaultUsableUntil(for: id))
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
