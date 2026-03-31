import XCTest
@testable import Entule

final class StoreTests: XCTestCase {
    func testStoreReadWrite() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("entule-tests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let customFM = TestFileManager(baseURL: root)
        let store = JSONStore(fileManager: customFM)

        var state = AppStateModel.empty
        state.presets = [Preset(name: "Dev", items: [])]
        try store.saveState(state)

        let loaded = try store.loadState()
        XCTAssertEqual(loaded.presets.count, 1)
        XCTAssertEqual(loaded.presets.first?.name, "Dev")
    }

    func testStateFileUsesEntuleDirectory() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("entule-path-tests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let customFM = TestFileManager(baseURL: root)
        let stateURL = try FilePaths.stateFileURL(fileManager: customFM)
        XCTAssertTrue(stateURL.path.contains("/Entule/state.json"))
    }

    func testLegacyMigrationWhenEntuleStateMissing() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("entule-migration-tests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let customFM = TestFileManager(baseURL: root)

        let legacyDir = root.appendingPathComponent("WorkCheckpoint", isDirectory: true)
        try fileManager.createDirectory(at: legacyDir, withIntermediateDirectories: true)
        let legacyURL = legacyDir.appendingPathComponent("state.json")

        var legacy = AppStateModel.empty
        legacy.presets = [Preset(name: "LegacyPreset", items: [])]

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(legacy)
        try data.write(to: legacyURL, options: .atomic)

        let store = JSONStore(fileManager: customFM)
        let loaded = try store.loadState()

        XCTAssertEqual(loaded.presets.first?.name, "LegacyPreset")

        let entuleStateURL = root
            .appendingPathComponent("Entule", isDirectory: true)
            .appendingPathComponent("state.json", isDirectory: false)
        XCTAssertTrue(fileManager.fileExists(atPath: entuleStateURL.path))
    }

    func testResetStateRecreatesCleanEmptyState() throws {
        let fileManager = FileManager.default
        let root = fileManager.temporaryDirectory.appendingPathComponent("entule-reset-tests-\(UUID().uuidString)")
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let customFM = TestFileManager(baseURL: root)
        let store = JSONStore(fileManager: customFM)

        var state = AppStateModel.empty
        state.presets = [Preset(name: "ToDelete", items: [])]
        try store.saveState(state)

        try store.resetState()
        let loaded = try store.loadState()
        XCTAssertTrue(loaded.presets.isEmpty)
        XCTAssertNil(loaded.lastSnapshot)
    }
}

final class TestFileManager: FileManager {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
        super.init()
    }

    override func urls(for directory: SearchPathDirectory, in domainMask: SearchPathDomainMask) -> [URL] {
        if directory == .applicationSupportDirectory {
            return [baseURL]
        }
        return super.urls(for: directory, in: domainMask)
    }
}
