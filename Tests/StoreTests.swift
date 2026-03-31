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
