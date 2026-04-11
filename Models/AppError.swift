import Foundation

enum AppError: LocalizedError, Equatable {
    case failure(String)

    var errorDescription: String? {
        switch self {
        case let .failure(message):
            return message
        }
    }
}
