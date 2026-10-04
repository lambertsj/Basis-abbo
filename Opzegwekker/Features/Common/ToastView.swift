import SwiftUI

/// "Verwijderd · Ongedaan maken" at the bottom of the screen.
struct ToastView: View {
    let toast: AppModel.Toast
    let onUndo: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                content
            }
            VStack(spacing: 6) {
                content
            }
        }
        .font(.subheadline)
        .foregroundStyle(Color.paper)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.ink, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Ongedaan maken", onUndo)
    }

    @ViewBuilder
    private var content: some View {
        Text(toast.message)
            .fixedSize(horizontal: false, vertical: true)
        if toast.undo != nil {
            Text("·")
                .opacity(0.5)
                .accessibilityHidden(true)
            Button(action: onUndo) {
                Text("Ongedaan maken")
                    .fontWeight(.semibold)
                    .underline()
                    .foregroundStyle(Color.paper)
            }
            .buttonStyle(.plain)
        }
    }
}
