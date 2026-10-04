#if DEBUG
import Foundation
import SwiftData

/// Sample data for development. Only exists in DEBUG builds; load it with the launch
/// argument `-OpzegwekkerSeed` or from Instellingen.
enum DebugSeed {
    static func populate(context: ModelContext, today: CalendarDay, catalog: Catalog) {
        let existing = (try? context.fetchCount(FetchDescriptor<Item>())) ?? 0
        guard existing == 0 else { return }
        let now = Date()

        func make(_ name: String, _ catalogID: String?, _ build: (inout ItemData) -> Void) -> ItemData {
            var item = ItemData(
                name: name,
                catalogID: catalogID,
                kind: .trial,
                status: .trial,
                startDate: today.adding(days: -10),
                createdAt: now,
                updatedAt: now
            )
            build(&item)
            return item
        }

        let samples: [ItemData] = [
            make("Videoland", "videoland") {
                $0.trialEnd = today.adding(days: 1)
                $0.priceCents = 999
            },
            make("NRC", "nrc") {
                $0.trialEnd = today.adding(days: 5)
                $0.priceCents = 1950
            },
            make("Storytel", "storytel") {
                $0.trialEnd = today.adding(days: 20)
            },
            make("Microsoft 365", "microsoft-365") {
                $0.kind = .subscription
                $0.status = .active
                $0.interval = .year
                $0.anchor = today.adding(days: 25)
                $0.priceCents = 9900
            },
            make("Basic-Fit", "basic-fit") {
                $0.kind = .subscription
                $0.status = .active
                $0.interval = .month
                $0.anchor = today.adding(days: -40)
                $0.priceCents = 2999
                $0.noticeValue = 1
                $0.noticeUnit = .months
            },
            make("Netflix", "netflix") {
                $0.kind = .subscription
                $0.status = .active
                $0.interval = .month
                $0.anchor = today.adding(days: 12)
                $0.priceCents = 1399
            },
            make("Sportschool jaarcontract", nil) {
                $0.kind = .subscription
                $0.status = .active
                $0.interval = .fixedEnd
                $0.anchor = today.adding(days: 60)
                $0.priceCents = 2500
            },
            make("Disney+", "disney-plus") {
                $0.trialEnd = today.adding(days: -3)
                $0.priceCents = 1199
            },
            make("HelloFresh", "hellofresh") {
                $0.kind = .subscription
                $0.status = .cancelled
                $0.interval = .week
                $0.anchor = today.adding(days: 4)
                $0.usableUntil = today.adding(days: 4)
                $0.priceCents = 4500
            },
            make("Spotify", "spotify") {
                $0.kind = .subscription
                $0.status = .stopped
                $0.interval = .month
                $0.anchor = today.adding(days: -30)
                $0.usableUntil = today.adding(days: -30)
                $0.priceCents = 1199
            },
        ]
        for sample in samples {
            context.insert(Item(data: sample))
        }
        try? context.save()
    }
}
#endif
