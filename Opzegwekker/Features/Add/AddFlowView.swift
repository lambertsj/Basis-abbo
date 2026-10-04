import SwiftUI

/// The add sheet: step 1 search, step 2 the form, pushed within the same sheet.
struct AddFlowView: View {
    enum Step: Hashable {
        case form(serviceID: String?, name: String)
    }

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var path: [Step]

    init(start: AppModel.AddStart) {
        switch start {
        case .search:
            _path = State(initialValue: [])
        case .service(let id):
            _path = State(initialValue: [.form(serviceID: id, name: "")])
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            AddSearchView { service, name in
                path.append(.form(serviceID: service?.id, name: name))
            }
            .navigationDestination(for: Step.self) { step in
                switch step {
                case let .form(serviceID, name):
                    ItemFormView(
                        draft: ItemDraft(name: name, service: model.catalog.service(id: serviceID), today: model.today),
                        isNew: true
                    ) { draft in
                        model.save(draft)
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuleer") { dismiss() }
                }
            }
        }
    }
}
