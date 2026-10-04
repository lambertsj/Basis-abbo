import SwiftUI

/// Shown when there are no items at all: one question and chips to start right away.
struct EmptyStateView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Welke proefperiode wil je niet vergeten?")
                    .font(.serif(.largeTitle))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.top, 24)

                FlowLayout(spacing: 10) {
                    ForEach(model.catalog.popular) { service in
                        Button {
                            model.sheet = .add(.service(service.id))
                        } label: {
                            HStack(spacing: 8) {
                                LetterIcon(name: service.name, category: service.category, size: 24)
                                Text(service.name)
                            }
                        }
                        .buttonStyle(ChipStyle())
                    }
                    Button {
                        model.sheet = .add(.search)
                    } label: {
                        Label("Iets anders", systemImage: "plus")
                    }
                    .buttonStyle(ChipStyle())
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.paper)
    }
}
