import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case home
    case saveSession
    case resumeSession
    case presets
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Overview"
        case .saveSession:
            return "Save Session"
        case .resumeSession:
            return "Resume Session"
        case .presets:
            return "Presets"
        case .settings:
            return "Settings"
        }
    }

    var subtitle: String {
        switch self {
        case .home:
            return "A quick snapshot of what Entule can reopen for you."
        case .saveSession:
            return "Review what Entule detected, trim the noise, and save a checkpoint."
        case .resumeSession:
            return "Reopen the latest checkpoint and inspect the launch result."
        case .presets:
            return "Build reusable launch sets for the work you repeat often."
        case .settings:
            return "Testing tools, local storage controls, and diagnostics."
        }
    }

    var symbolName: String {
        switch self {
        case .home:
            return "square.grid.2x2"
        case .saveSession:
            return "square.and.arrow.down"
        case .resumeSession:
            return "arrow.clockwise"
        case .presets:
            return "bookmark"
        case .settings:
            return "gearshape"
        }
    }
}
