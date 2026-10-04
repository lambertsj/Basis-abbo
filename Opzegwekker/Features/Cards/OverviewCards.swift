import SwiftUI

/// "Meldingen staan uit." Can be swiped away; returns after the next addition.
struct NotificationsDeniedCard: View {
    let onEnable: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Label {
                    Text("Meldingen staan uit. Je ziet je deadlines nu alleen hier en in de widget.")
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "bell.slash")
                        .foregroundStyle(.orange)
                }
                Spacer(minLength: 4)
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Verberg")
            }
            Button("Zet aan", action: onEnable)
                .buttonStyle(ChipStyle(isSelected: true))
        }
        .cardStyle()
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Verberg", action: onDismiss)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button("Verberg", action: onDismiss)
        }
        .accessibilityAction(named: "Verberg", onDismiss)
    }
}

/// "<naam> loopt nu waarschijnlijk door. Klopt dat?"
struct ConfirmationCard: View {
    let name: String
    let onConfirm: () -> Void
    let onAlreadyCancelled: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(Text(name).font(.serif(.body, weight: .semibold))) loopt nu waarschijnlijk door. Klopt dat?")
                .fixedSize(horizontal: false, vertical: true)
            ViewThatFits(in: .horizontal) {
                HStack {
                    buttons
                }
                VStack(alignment: .leading) {
                    buttons
                }
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private var buttons: some View {
        Button("Klopt", action: onConfirm)
            .buttonStyle(ChipStyle(isSelected: true))
        Button("Ik had al opgezegd", action: onAlreadyCancelled)
            .buttonStyle(ChipStyle())
    }
}

private extension View {
    /// A card as a note on the page: raised paper with a hairline edge.
    func cardStyle() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.paperRaised, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.hairline, lineWidth: 1))
    }
}
