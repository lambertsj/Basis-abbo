import SwiftUI

/// Letter icon, name, a subtitle and the remaining days on the right.
struct ItemRow: View {
    let item: ItemData
    let category: ServiceCategory
    let texts: ItemTexts

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 40

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    LetterIcon(name: item.name, category: category, size: iconSize)
                    labels
                    daysLeft
                }
            } else {
                HStack(spacing: 12) {
                    LetterIcon(name: item.name, category: category, size: min(iconSize, 56))
                    labels
                    Spacer(minLength: 8)
                    daysLeft
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(texts.accessibilityLabel)
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.name)
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.ink)
            Text(texts.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var daysLeft: some View {
        if let text = texts.daysLeftText, let days = texts.daysLeft {
            DaysLeftLabel(days: days, text: text, urgency: texts.urgency)
                .multilineTextAlignment(.trailing)
        }
    }
}
