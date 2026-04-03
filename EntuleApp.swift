import SwiftUI

@main
struct EntuleApp: App {
    @StateObject private var container = AppContainer.shared
    @NSApplicationDelegateAdaptor(EntuleAppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Entule", systemImage: "checklist") {
            MenuBarRootView(
                workspaceViewModel: container.workspaceViewModel,
                appShellViewModel: container.appShellViewModel,
                appShellController: container.appShellController
            )
        }
        .menuBarExtraStyle(.menu)
    }
}

final class EntuleAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = AppContainer.shared.appShellController
        controller.hideToMenuBarIfPossible()
        DispatchQueue.main.async {
            controller.showMainWindow(section: nil)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        AppContainer.shared.appShellController.handleAppReopen()
        return true
    }
}

@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()

    let appState: AppState
    let workspaceViewModel: WorkspaceViewModel
    let appShellViewModel: AppShellViewModel
    let appShellController: AppShellController

    init() {
        let appState = AppState()
        self.appState = appState
        
        let workspaceViewModel = WorkspaceViewModel(appState: appState)
        self.workspaceViewModel = workspaceViewModel
        
        let appShellViewModel = AppShellViewModel()
        self.appShellViewModel = appShellViewModel
        
        self.appShellController = AppShellController(
            appShellViewModel: appShellViewModel,
            workspaceViewModel: workspaceViewModel
        )
        
        self.workspaceViewModel.reload()
    }
}
