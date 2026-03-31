import SwiftUI

@main
struct EntuleApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var menuBarViewModel: MenuBarViewModel

    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        _menuBarViewModel = StateObject(wrappedValue: MenuBarViewModel(appState: appState))
    }

    var body: some Scene {
        MenuBarExtra("Entule", systemImage: "checklist") {
            MenuBarRootView(viewModel: menuBarViewModel)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
        }
    }
}
