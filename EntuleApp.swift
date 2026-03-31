import SwiftUI

@main
struct EntuleApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        MenuBarExtra("Entule", systemImage: "checklist") {
            MenuBarRootView(viewModel: container.menuBarViewModel)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(menuBarViewModel: container.menuBarViewModel)
        }
    }
}

@MainActor
final class AppContainer: ObservableObject {
    let appState: AppState
    let menuBarViewModel: MenuBarViewModel

    init() {
        let appState = AppState()
        self.appState = appState
        self.menuBarViewModel = MenuBarViewModel(appState: appState)
        self.menuBarViewModel.reload()
    }
}
