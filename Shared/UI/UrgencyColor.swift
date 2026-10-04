import SwiftUI

extension Urgency {
    /// Red, orange or secondary. Always shown together with text, never on its own.
    var color: Color {
        switch self {
        case .high: .red
        case .medium: .orange
        case .normal: .secondary
        }
    }
}
