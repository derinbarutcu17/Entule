import Foundation

@MainActor
final class AppShellViewModel: ObservableObject {
    @Published var activeSection: AppSection = .home
    @Published var statusLine: String = "Ready"

    func openPresets() {
        setSection(.presets)
    }

    func openSettings() {
        setSection(.settings)
    }

    func showHome() {
        setSection(.home)
    }

    func showSaveSession() {
        setSection(.saveSession)
    }

    func inspectCheckpoint() {
        setSection(.inspectCheckpoint)
    }

    func navigate(to section: AppSection) {
        setSection(section)
    }

    private func setSection(_ section: AppSection) {
        activeSection = section
        statusLine = section.statusLine
    }
}
