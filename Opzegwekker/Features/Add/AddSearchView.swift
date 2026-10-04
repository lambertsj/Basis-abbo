import SwiftUI

/// Step 1: search the catalog, or add something that is not in it.
struct AddSearchView: View {
    /// False while the form is pushed on top; the field gets focus whenever this
    /// screen is the visible one.
    let isActive: Bool
    /// Called with the chosen service, or nil and the typed name for a custom item.
    let onPick: (CatalogService?, String) -> Void

    @Environment(AppModel.self) private var model
    @State private var query = ""
    @FocusState private var isFocused: Bool

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if trimmedQuery.isEmpty {
                popularGrid
            } else {
                results
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            searchField
        }
        .navigationTitle("Toevoegen")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isActive, initial: true) { _, active in
            if active { isFocused = true }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField("Zoek een dienst", text: $query)
                .focused($isFocused)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .onSubmit(submit)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }

    private var popularGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 16) {
                ForEach(model.catalog.popular) { service in
                    Button {
                        onPick(service, service.name)
                    } label: {
                        VStack(spacing: 8) {
                            LetterIcon(name: service.name, category: service.category, size: 52)
                            Text(service.name)
                                .font(.footnote)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var results: some View {
        let matches = model.catalog.search(trimmedQuery)
        let exact = model.catalog.exactMatch(trimmedQuery)
        return List {
            if exact == nil {
                Button {
                    onPick(nil, trimmedQuery)
                } label: {
                    Label("‘\(trimmedQuery)’ toevoegen", systemImage: "plus")
                }
            }
            ForEach(matches) { service in
                Button {
                    onPick(service, service.name)
                } label: {
                    HStack(spacing: 12) {
                        LetterIcon(name: service.name, category: service.category, size: 32)
                        Text(service.name)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    /// Return picks the exact match, else the "+ … toevoegen" row.
    private func submit() {
        guard !trimmedQuery.isEmpty else { return }
        if let exact = model.catalog.exactMatch(trimmedQuery) {
            onPick(exact, exact.name)
        } else {
            onPick(nil, trimmedQuery)
        }
    }
}
