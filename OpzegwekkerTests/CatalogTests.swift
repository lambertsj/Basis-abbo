import Foundation
import Testing
#if SWIFT_PACKAGE
@testable import OpzegwekkerCore
#else
@testable import Opzegwekker
#endif

@Suite("Catalogus")
struct CatalogTests {
    /// Decodes services.json loosely, so invalid enum values show up as test failures
    /// instead of an empty catalog.
    private func rawServices() throws -> [[String: Any]] {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        let url = try #require(
            bundle.url(forResource: "services", withExtension: "json")
                ?? Bundle.allBundles.lazy.compactMap { $0.url(forResource: "services", withExtension: "json") }.first
        )
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        let root = try #require(object as? [String: Any])
        return try #require(root["services"] as? [[String: Any]])
    }

    // 14
    @Test("Unieke ids, geldige enums, precies 8 populair")
    func catalogIsValid() throws {
        let raw = try rawServices()
        let ids = raw.compactMap { $0["id"] as? String }
        #expect(ids.count == raw.count)
        #expect(Set(ids).count == ids.count, "ids zijn niet uniek")

        for service in raw {
            let id = service["id"] as? String ?? "?"
            #expect(ServiceCategory(rawValue: service["category"] as? String ?? "") != nil, "categorie van \(id)")
            #expect(ServiceCategory(rawValue: service["category"] as? String ?? "") != .other, "categorie van \(id)")
            #expect(Kind(rawValue: service["defaultKind"] as? String ?? "") != nil, "defaultKind van \(id)")
            if let interval = service["defaultInterval"] as? String {
                #expect(BillingInterval(rawValue: interval) != nil, "defaultInterval van \(id)")
            }
            #expect(service["trialDays"] is NSNull, "trialDays van \(id) moet null blijven")
            #expect(service["cancelURL"] is NSNull, "cancelURL van \(id) moet null blijven")
        }

        let catalog = Catalog.bundled
        #expect(catalog.services.count == raw.count)
        #expect(catalog.popular.count == 8)
        #expect((35...50).contains(catalog.services.count))
        let categories = Set(catalog.services.map(\.category))
        #expect(categories == Set(ServiceCategory.allCases).subtracting([.other]))
    }

    @Test("Zoeken op naam en alias, zonder hoofdletters en accenten")
    func search() {
        let catalog = Catalog(version: 1, services: [
            CatalogService(id: "a", name: "Café Crème", aliases: ["Koffie"], category: .other, defaultKind: .trial,
                           defaultInterval: .month, trialDays: nil, cancelURL: nil, domains: [], appleBilling: false, popular: false),
            CatalogService(id: "b", name: "NRC", aliases: ["NRC Handelsblad"], category: .news, defaultKind: .trial,
                           defaultInterval: .month, trialDays: nil, cancelURL: nil, domains: [], appleBilling: false, popular: true),
        ])
        #expect(catalog.search("cafe").map(\.id) == ["a"])
        #expect(catalog.search("KOFF").map(\.id) == ["a"])
        #expect(catalog.search("handels").map(\.id) == ["b"])
        #expect(catalog.exactMatch("nrc")?.id == "b")
        #expect(catalog.exactMatch("café creme")?.id == "a")
        #expect(catalog.exactMatch("nr") == nil)
        #expect(catalog.search("  ").isEmpty)
    }
}
