import Foundation
import SwiftData

/// Creates the SwiftData container in the App Group, shared by the app and the widget.
enum Store {
    enum StoreError: Error { case appGroupUnavailable }

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
            // SwiftData stops the process instead of throwing when the group is missing from
            // the entitlements, so check first and let the caller fall back.
            guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
                throw StoreError.appGroupUnavailable
            }
            // A fresh group container has no Application Support yet; without it Core Data
            // logs an error and recovers on its own.
            try? FileManager.default.createDirectory(
                at: groupURL.appendingPathComponent("Library/Application Support", isDirectory: true),
                withIntermediateDirectories: true
            )
            configuration = ModelConfiguration(
                schema: schema,
                groupContainer: .identifier(appGroupIdentifier),
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
