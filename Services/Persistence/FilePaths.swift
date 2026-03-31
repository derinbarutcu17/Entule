import Foundation

enum FilePaths {
    static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        guard let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw AppError.persistenceFailed("Could not resolve Application Support directory")
        }

        let directory = base.appendingPathComponent("WorkCheckpoint", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    static func stateFileURL(fileManager: FileManager = .default) throws -> URL {
        try applicationSupportDirectory(fileManager: fileManager)
            .appendingPathComponent("state.json", isDirectory: false)
    }
}
