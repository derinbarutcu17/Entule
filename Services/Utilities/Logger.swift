import Foundation

final class Logger {
    static let shared = Logger()

    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private init() {}

    func info(_ message: String) {
        print("[INFO] [\(formatter.string(from: Date()))] \(message)")
    }

    func error(_ message: String) {
        fputs("[ERROR] [\(formatter.string(from: Date()))] \(message)\n", stderr)
    }
}
