import SwiftUI

struct MenuBarRootView: View {
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    @ObservedObject var appShellViewModel: AppShellViewModel
    let appShellController: AppShellController

    var body: some View {
        Group {
            Button("Open Entule") {
                appShellController.showMainWindow(section: appShellViewModel.activeSection)
            }

            Divider()

            SessionActionsView(
                canResume: workspaceViewModel.canResumeLastSession,
                isBusy: workspaceViewModel.isBusy,
                onResume: {
                    Task { _ = await workspaceViewModel.resumeLastSnapshot() }
                },
                onSave: {
                    appShellController.showMainWindow(section: .saveSession)
                }
            )

            PresetListView(presets: workspaceViewModel.presets, isBusy: workspaceViewModel.isBusy) { preset in
                Task { await workspaceViewModel.launchPreset(preset) }
            }

            Divider()

            Button("Presets…") {
                appShellController.showMainWindow(section: .presets)
            }

            Button("Settings…") {
                appShellController.showMainWindow(section: .settings)
            }

            Divider()

            Text(appShellViewModel.statusLine)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
