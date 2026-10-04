import Foundation
import OSLog
import SwiftData

/// Owns the long-lived objects, shared by the SwiftUI scene, the notification delegate
/// and the background task.
@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let container: ModelContainer
    let model: AppModel

    private init() {
        let container: ModelContainer
        do {
            container = try Store.makeContainer()
        } catch {
            // Without the App Group store the app still works for this session.
            Logger(subsystem: "Opzegwekker", category: "store")
                .error("Opening the store failed: \(error.localizedDescription, privacy: .public)")
            do {
                container = try Store.makeContainer(inMemory: true)
            } catch {
                fatalError("Cannot create an in-memory store: \(error)")
            }
        }
        self.container = container
        model = AppModel(container: container)
    }
}
