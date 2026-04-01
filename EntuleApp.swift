import SwiftUI

@main
struct EntuleApp: App {
    @StateObject private var container = AppContainer.shared
    @NSApplicationDelegateAdaptor(EntuleAppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Entule", systemImage: "checklist") {
            MenuBarRootView(viewModel: container.menuBarViewModel)
        }
        .menuBarExtraStyle(.menu)
    }
}

final class EntuleAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            let viewModel = AppContainer.shared.menuBarViewModel
            AppWindowController.shared.showDashboard(menuBarViewModel: viewModel)
        }
    }
}

@MainActor
final class AppContainer: ObservableObject {
    static let shared = AppContainer()

    let appState: AppState
    let menuBarViewModel: MenuBarViewModel

    init() {
        let appState = AppState()
        self.appState = appState
        self.menuBarViewModel = MenuBarViewModel(appState: appState)
        self.menuBarViewModel.reload()
    }
}
