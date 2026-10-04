import StoreKit
import SwiftUI

/// The single navigation stack with the overview, plus app-wide sheets and the toast.
struct RootView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        @Bindable var model = model
        NavigationStack(path: $model.path) {
            OverviewView()
                .navigationDestination(for: AppModel.Route.self) { route in
                    switch route {
                    case .item(let id):
                        ItemDetailView(itemID: id)
                    }
                }
        }
        .sheet(item: $model.sheet) { sheet in
            switch sheet {
            case .settings:
                Text("Instellingen")
            case .add(let start):
                AddFlowView(start: start)
            case .markCancelled(let id):
                MarkCancelledSheet(itemID: id)
            case .cancelSucceeded(let id):
                CancelSucceededSheet(itemID: id)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = model.toast {
                ToastView(toast: toast) { model.performToastUndo() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sensoryFeedback(.success, trigger: model.successHaptic)
        .sensoryFeedback(.impact(weight: .light), trigger: model.lightHaptic)
        .task { await model.start() }
        .onChange(of: scenePhase) { _, phase in
            model.scenePhaseChanged(phase)
        }
        .onChange(of: model.urlToOpen, initial: true) { _, url in
            guard let url else { return }
            model.urlToOpen = nil
            openURL(url)
        }
        .onChange(of: model.reviewRequest) {
            requestReview()
        }
    }
}
