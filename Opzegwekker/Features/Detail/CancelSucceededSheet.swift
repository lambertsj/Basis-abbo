import SwiftData
import SwiftUI

/// "Is opzeggen van … gelukt?" when returning from the cancel page.
struct CancelSucceededSheet: View {
    let itemID: UUID

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Query private var matches: [Item]

    init(itemID: UUID) {
        self.itemID = itemID
        let id = itemID
        _matches = Query(filter: #Predicate<Item> { $0.id == id })
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Is opzeggen van \(matches.first?.name ?? "dit abonnement") gelukt?")
                .font(.serif(.title2))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 24)
            Spacer(minLength: 0)
            Button {
                model.confirmCancelSucceeded(itemID)
                dismiss()
            } label: {
                Text("Ja, opgezegd")
            }
            .buttonStyle(PrimaryButtonStyle())
            Button {
                dismiss()
            } label: {
                Text("Nog niet")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(16)
        .presentationBackground(Color.paper)
        .presentationDetents([.medium])
    }
}
