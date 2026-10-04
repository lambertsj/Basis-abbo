import SwiftUI

/// Shown when there are no items at all: one question and chips to start right away.
struct EmptyStateView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Welke proefperiode wil je niet vergeten?")
                    .font(.title2.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

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
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// A rounded, tinted chip.
struct ChipStyle: ButtonStyle {
    var isSelected = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(
                Capsule().fill(isSelected ? Color.accentColor : Color(.secondarySystemFill))
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
            .contentShape(Capsule())
    }
}
