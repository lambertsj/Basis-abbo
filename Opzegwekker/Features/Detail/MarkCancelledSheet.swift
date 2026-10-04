import SwiftUI

/// "Tot wanneer kun je het nog gebruiken?" after the Opgezegd swipe.
struct MarkCancelledSheet: View {
    let itemID: UUID

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tot wanneer kun je het nog gebruiken?")
                    .font(.serif(.title2))
                    .fixedSize(horizontal: false, vertical: true)
                DatePicker("Gebruiken tot", selection: $date, displayedComponents: .date)
                Spacer(minLength: 0)
                Button {
                    model.markCancelled(itemID, usableUntil: CalendarDay(date, calendar: model.calendar))
                    dismiss()
                } label: {
                    Text("Bevestig")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.paper)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
            }
        }
        .presentationBackground(Color.paper)
        .presentationDetents([.medium, .large])
        .onAppear {
            let day = model.defaultUsableUntil(for: itemID)
            date = day.date(hour: 12, minute: 0, calendar: model.calendar) ?? Date()
        }
    }
}
