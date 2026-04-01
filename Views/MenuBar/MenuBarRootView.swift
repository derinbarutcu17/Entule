import SwiftUI

struct MenuBarRootView: View {
    @ObservedObject var viewModel: MenuBarViewModel

    var body: some View {
        Group {
            Button("Open Entule") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    AppWindowController.shared.showDashboard(menuBarViewModel: viewModel)
                }
            }

            Divider()

            SessionActionsView(
                canResume: viewModel.canResumeLastSession,
                isBusy: viewModel.isBusy,
                onResume: {
                    viewModel.beginResumeSession()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        AppWindowController.shared.showResumeSession(menuBarViewModel: viewModel)
                    }
                },
                onSave: {
                    viewModel.beginSaveSession()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        AppWindowController.shared.showSaveSession(menuBarViewModel: viewModel)
                    }
                }
            )

            PresetListView(presets: viewModel.presets, isBusy: viewModel.isBusy) { preset in
                Task { await viewModel.launchPreset(preset) }
            }

            Divider()

            Button("Presets…") {
                viewModel.openPresets()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    AppWindowController.shared.showPresets(menuBarViewModel: viewModel)
                }
            }

            Button("Settings…") {
                viewModel.openSettings()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    AppWindowController.shared.showSettings(menuBarViewModel: viewModel)
                }
            }

            Divider()

            Text(viewModel.statusLine)
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
