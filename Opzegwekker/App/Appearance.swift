import UIKit

/// Navigation bar in the app's paper-and-ink style, with serif titles.
enum Appearance {
    static func configure() {
        let ink = UIColor(named: "Ink") ?? .label
        let paper = UIColor(named: "Paper") ?? .systemBackground
        let largeTitle = serif(.largeTitle, weight: .semibold)
        let title = serif(.headline, weight: .semibold)

        let standard = UINavigationBarAppearance()
        standard.configureWithOpaqueBackground()
        standard.backgroundColor = paper
        standard.shadowColor = ink.withAlphaComponent(0.12)
        standard.largeTitleTextAttributes = [.font: largeTitle, .foregroundColor: ink]
        standard.titleTextAttributes = [.font: title, .foregroundColor: ink]

        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.configureWithTransparentBackground()
        scrollEdge.backgroundColor = paper
        scrollEdge.largeTitleTextAttributes = standard.largeTitleTextAttributes
        scrollEdge.titleTextAttributes = standard.titleTextAttributes

        let bar = UINavigationBar.appearance()
        bar.standardAppearance = standard
        bar.compactAppearance = standard
        bar.scrollEdgeAppearance = scrollEdge
        bar.tintColor = ink
    }

    /// New York in a Dynamic Type text style.
    private static func serif(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        let weighted = base.fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        let descriptor = weighted.withDesign(.serif) ?? weighted
        return UIFont(descriptor: descriptor, size: 0)
    }
}
