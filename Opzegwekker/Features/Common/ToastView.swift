import SwiftUI

/// "Verwijderd · Ongedaan maken" at the bottom of the screen.
struct ToastView: View {
    let toast: AppModel.Toast
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(toast.message)
                .foregroundStyle(.primary)
            if toast.undo != nil {
                Text("·")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Button("Ongedaan maken", action: onUndo)
                    .fontWeight(.semibold)
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityAction(named: "Ongedaan maken", onUndo)
    }
}
