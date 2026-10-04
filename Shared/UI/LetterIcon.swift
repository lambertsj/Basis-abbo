import SwiftUI

/// The first letter of a name, in the category colour on a soft tint of it.
/// No brand logos.
struct LetterIcon: View {
    let name: String
    let category: ServiceCategory
    var size: CGFloat = 40

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(category.color.opacity(0.16))
            .frame(width: size, height: size)
            .overlay {
                Text(letter)
                    .font(.system(size: size * 0.48, weight: .semibold, design: .serif))
                    .foregroundStyle(category.color)
                    .minimumScaleFactor(0.5)
            }
            .accessibilityHidden(true)
    }

    private var letter: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? "?"
    }
}
