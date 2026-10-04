import SwiftUI

/// The visual language of Opzegwekker: a paper agenda.
///
/// - Warm paper and ink instead of grey and blue. Colour only appears where it means
///   something: urgency and the category of an item.
/// - A serif (New York) for what matters most: dates, amounts and titles. Everything
///   else uses the system font, so it stays a native iOS app.
extension Color {
    /// Warm off-white page; warm near-black in dark mode.
    static let paper = Color("Paper")
    /// Surfaces that sit on the page, such as form rows.
    static let paperRaised = Color("PaperRaised")
    /// Text and primary controls.
    static let ink = Color("Ink")
    /// Separators and outlines.
    static let hairline = Color("Ink").opacity(0.12)
}

extension Font {
    /// Serif in a Dynamic Type text style, for dates, amounts and titles.
    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif, weight: weight)
    }
}

/// Filled ink button: the one thing to do on a screen.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.paper)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 16)
            .background(Color.ink, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.75 : 1)
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Outlined ink button for the alternatives.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.ink)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.ink.opacity(0.25), lineWidth: 1)
            )
            .background(configuration.isPressed ? Color.hairline : Color.clear, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Small outlined pill; filled with ink when selected.
struct ChipStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Color.paper : Color.ink)
            .background(Capsule().fill(isSelected ? Color.ink : Color.clear))
            .overlay(Capsule().strokeBorder(Color.ink.opacity(isSelected ? 0 : 0.22), lineWidth: 1))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Capsule())
    }
}

/// Small spaced capitals above a group: "NU BESLISSEN · 2".
struct GroupLabel: View {
    let title: String
    var count: Int?

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
            if let count {
                Text("·")
                    .accessibilityHidden(true)
                Text("\(count)")
                    .monospacedDigit()
            }
        }
        .font(.caption.weight(.semibold))
        .tracking(1.2)
        .textCase(.uppercase)
        .foregroundStyle(.secondary)
    }
}

/// "nog 3 dagen" with the number set large in serif; "vandaag" and "morgen" in bold.
/// Always text, never colour alone.
struct DaysLeftLabel: View {
    let days: Int
    let text: String
    let urgency: Urgency

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if days >= 2 && !dynamicTypeSize.isAccessibilitySize {
                Text("nog \(Text("\(days)").font(.serif(.title3, weight: .semibold)).monospacedDigit()) dagen")
                    .font(.subheadline)
            } else {
                Text(text)
                    .font(.subheadline.weight(urgency == .normal ? .regular : .semibold))
            }
        }
        .foregroundStyle(urgency.color)
    }
}

extension View {
    /// Paper page behind lists and forms instead of the system grey.
    func paperBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Color.paper)
    }
}
