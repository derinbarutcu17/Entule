import Foundation

enum URLNormalizer {
    static func normalize(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let withScheme: String
        if trimmed.contains("://") {
            withScheme = trimmed
        } else {
            withScheme = "https://\(trimmed)"
        }

        guard var components = URLComponents(string: withScheme),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host,
              !host.isEmpty else {
            return nil
        }

        components.scheme = scheme
        components.host = host.lowercased()
        if components.path.isEmpty { components.path = "/" }

        return components.url?.absoluteString
    }
}
