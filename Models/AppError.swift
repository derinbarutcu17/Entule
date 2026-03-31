import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidURL(String)
    case fileNotFound(String)
    case appNotFound(String)
    case launchFailed(String)
    case shortcutFailed(String)
    case persistenceFailed(String)
    case detectionFailed(String)

    var errorDescription: String? {
        switch self {
        case let .invalidURL(value):
            return "Invalid URL: \(value)"
        case let .fileNotFound(path):
            return "File/folder not found: \(path)"
        case let .appNotFound(path):
            return "App not found: \(path)"
        case let .launchFailed(message):
            return "Launch failed: \(message)"
        case let .shortcutFailed(message):
            return "Shortcut failed: \(message)"
        case let .persistenceFailed(message):
            return "Persistence failed: \(message)"
        case let .detectionFailed(message):
            return "Detection failed: \(message)"
        }
    }
}
