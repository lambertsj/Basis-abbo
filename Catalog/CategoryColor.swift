import SwiftUI

extension ServiceCategory {
    /// Fixed letter-icon colour per category. System colours adapt to light and dark mode.
    var color: Color {
        switch self {
        case .streaming: .red
        case .music: .green
        case .news: .blue
        case .mealbox: .orange
        case .gym: .purple
        case .storage: .cyan
        case .software: .indigo
        case .audiobooks: .brown
        case .other: .gray
        }
    }
}
