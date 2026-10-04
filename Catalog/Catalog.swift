import Foundation

enum ServiceCategory: String, Codable, CaseIterable, Sendable {
    case streaming
    case music
    case news
    case mealbox
    case gym
    case storage
    case software
    case audiobooks
    case internet
    case mobile
    case energy
    case insurance
    /// Items without a catalog entry.
    case other
}

struct CatalogService: Codable, Hashable, Identifiable, Sendable {
    var id: String
    var name: String
    var aliases: [String]
    var category: ServiceCategory
    var defaultKind: Kind
    var defaultInterval: BillingInterval?
    var trialDays: Int?
    var cancelURL: String?
    var domains: [String]
    var appleBilling: Bool
    var popular: Bool
}

struct Catalog: Codable, Sendable {
    var version: Int
    var services: [CatalogService]

    static let empty = Catalog(version: 1, services: [])

    /// The catalog shipped with the app (`services.json`).
    static let bundled: Catalog = {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle.main
        #endif
        guard let url = bundle.url(forResource: "services", withExtension: "json"),
              let catalog = try? load(from: url)
        else { return .empty }
        return catalog
    }()

    static func load(from url: URL) throws -> Catalog {
        try decode(Data(contentsOf: url))
    }

    static func decode(_ data: Data) throws -> Catalog {
        try JSONDecoder().decode(Catalog.self, from: data)
    }

    func service(id: String?) -> CatalogService? {
        guard let id else { return nil }
        return services.first { $0.id == id }
    }

    var popular: [CatalogService] {
        services.filter(\.popular)
    }

    func category(for catalogID: String?) -> ServiceCategory {
        service(id: catalogID)?.category ?? .other
    }

    /// `defaultInterval` per service id, for the transition look-ahead.
    var defaultIntervals: [String: BillingInterval] {
        var result: [String: BillingInterval] = [:]
        for service in services {
            if let interval = service.defaultInterval { result[service.id] = interval }
        }
        return result
    }

    // MARK: - Search

    /// Lowercased, accents removed: "Équipe" → "equipe".
    static func normalized(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: Locale(identifier: "nl_NL"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Services whose name or an alias contains `query`; names starting with it first.
    func search(_ query: String) -> [CatalogService] {
        let needle = Catalog.normalized(query)
        guard !needle.isEmpty else { return [] }
        let matches = services.compactMap { service -> (CatalogService, Int)? in
            let names = [service.name] + service.aliases
            let normalizedNames = names.map(Catalog.normalized)
            if normalizedNames.contains(where: { $0 == needle }) { return (service, 0) }
            if normalizedNames.contains(where: { $0.hasPrefix(needle) }) { return (service, 1) }
            if normalizedNames.contains(where: { $0.contains(needle) }) { return (service, 2) }
            return nil
        }
        return matches.sorted { lhs, rhs in
            lhs.1 != rhs.1 ? lhs.1 < rhs.1 : lhs.0.name.localizedStandardCompare(rhs.0.name) == .orderedAscending
        }.map(\.0)
    }

    /// The service whose name or alias equals `query`, ignoring case and accents.
    func exactMatch(_ query: String) -> CatalogService? {
        let needle = Catalog.normalized(query)
        guard !needle.isEmpty else { return nil }
        return services.first { service in
            ([service.name] + service.aliases).contains { Catalog.normalized($0) == needle }
        }
    }
}
