import AppKit
import Foundation

protocol AppOpening {
    func openApplication(
        at applicationURL: URL,
        configuration: NSWorkspace.OpenConfiguration,
        completion: @escaping @Sendable (NSRunningApplication?, Error?) -> Void
    )
}

struct AppOpenAwaiterError: Error {
    let message: String
}

final class NSWorkspaceAppOpener: AppOpening {
    private let workspace: NSWorkspace

    init(workspace: NSWorkspace) {
        self.workspace = workspace
    }

    func openApplication(
        at applicationURL: URL,
        configuration: NSWorkspace.OpenConfiguration,
        completion: @escaping @Sendable (NSRunningApplication?, Error?) -> Void
    ) {
        workspace.openApplication(at: applicationURL, configuration: configuration, completionHandler: completion)
    }
}

struct AppOpenAwaiter {
    let opener: AppOpening

    init(opener: AppOpening) {
        self.opener = opener
    }

    func openApplication(at appURL: URL) async -> Result<Void, AppOpenAwaiterError> {
        await withCheckedContinuation { continuation in
            let configuration = NSWorkspace.OpenConfiguration()
            opener.openApplication(at: appURL, configuration: configuration) { runningApp, error in
                if let error {
                    continuation.resume(returning: .failure(AppOpenAwaiterError(message: error.localizedDescription)))
                    return
                }

                guard runningApp != nil else {
                    continuation.resume(returning: .failure(AppOpenAwaiterError(message: "openApplication returned no running app")))
                    return
                }

                continuation.resume(returning: .success(()))
            }
        }
    }
}
