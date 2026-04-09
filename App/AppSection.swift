import Foundation

enum AppSection: String, CaseIterable, Identifiable {
    case home
    case saveSession
    case inspectCheckpoint
    case presets
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            return "Overview"
        case .saveSession:
            return "Save Session"
        case .inspectCheckpoint:
            return "Inspect Checkpoint"
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
        case .inspectCheckpoint:
            return "Review the latest saved checkpoint before or after reopening it."
        case .presets:
            return "Build reusable launch sets for the work you repeat often."
        case .settings:
            return "Privacy, access, and the few controls most people actually need."
        }
    }

    var symbolName: String {
        switch self {
        case .home:
            return "square.grid.2x2"
        case .saveSession:
            return "square.and.arrow.down"
        case .inspectCheckpoint:
            return "arrow.clockwise"
        case .presets:
            return "bookmark"
        case .settings:
            return "gearshape"
        }
    }

    var statusLine: String {
        switch self {
        case .home:
            return "Ready"
        case .saveSession:
            return "Save session"
        case .inspectCheckpoint:
            return "Inspect checkpoint"
        case .presets:
            return "Presets"
        case .settings:
            return "Settings"
        }
    }
}
