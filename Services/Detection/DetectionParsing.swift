import Foundation

enum DetectionParsing {
    static let recordSeparator = Character(UnicodeScalar(30))
    static let fieldSeparator = Character(UnicodeScalar(31))

    static func parseFinderPaths(_ output: String) -> [String] {
        parseRecords(output)
            .compactMap { fields in fields.first }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func parseBrowserRows(_ output: String) -> [(title: String, url: String)] {
        parseRecords(output).compactMap { fields in
            guard fields.count >= 2 else { return nil }
            let title = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let url = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            return (title, url)
        }
    }

    private static func parseRecords(_ output: String) -> [[String]] {
        output
            .split(separator: recordSeparator)
            .map(String.init)
            .map { row in row.split(separator: fieldSeparator).map(String.init) }
    }
}
