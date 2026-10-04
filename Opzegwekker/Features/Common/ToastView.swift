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
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Ongedaan maken", onUndo)
    }

    @ViewBuilder
    private var content: some View {
        Text(toast.message)
            .foregroundStyle(.primary)
            .fixedSize(horizontal: false, vertical: true)
        if toast.undo != nil {
            Text("·")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Button("Ongedaan maken", action: onUndo)
                .fontWeight(.semibold)
        }
    }
}
