import Foundation

struct AppEnvironment {
    var store: Store
    var launcher: Launcher
    var detectionCoordinator: DetectionCoordinator
    var logger: Logger

    static let live = AppEnvironment(
        store: JSONStore(),
        launcher: NSWorkspaceLauncher(),
        detectionCoordinator: DetectionCoordinator(),
        logger: .shared
    )
}
