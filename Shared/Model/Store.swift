import Foundation
import SwiftData

/// Creates the SwiftData container in the App Group, shared by the app and the widget.
enum Store {
    /// Read from the `OpzegwekkerAppGroup` Info.plist key, which the build settings fill
    /// with `group.$(APP_BUNDLE_ID).shared`.
    static var appGroupIdentifier: String {
        Bundle.main.object(forInfoDictionaryKey: "OpzegwekkerAppGroup") as? String ?? "group.nl.basisapps.opzegwekker.shared"
    }

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([Item.self])
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                groupContainer: .identifier(appGroupIdentifier),
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
