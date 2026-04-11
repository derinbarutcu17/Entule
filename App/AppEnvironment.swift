import Foundation
import OSLog

struct AppEnvironment {
    var store: Store
    var launcher: Launcher
    var detectionCoordinator: DetectionCoordinator
    var logger: Logger

    static let live = AppEnvironment(
        store: JSONStore(),
        launcher: AppLauncher(),
        detectionCoordinator: DetectionCoordinator(),
        logger: .shared
    )
}

extension Logger {
    static let shared = Logger(subsystem: "com.entule.app", category: "General")
}
