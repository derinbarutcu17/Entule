import SwiftUI

struct MenuBarRootView: View {
    @ObservedObject var viewModel: MenuBarViewModel

    var body: some View {
        Group {
            SessionActionsView(
                canResume: viewModel.canResumeLastSession,
                isBusy: viewModel.isBusy,
                onResume: { viewModel.beginResumeSession() },
                onSave: { viewModel.beginSaveSession() }
            )

            PresetListView(presets: viewModel.presets, isBusy: viewModel.isBusy) { preset in
                Task { await viewModel.launchPreset(preset) }
            }

            Divider()

            Button("Presets…") {
                viewModel.openPresets()
            }

            Button("Settings…") {
                viewModel.openSettings()
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
        .sheet(isPresented: $viewModel.showSaveSheet) {
            SaveSessionSheet(viewModel: SaveSessionViewModel(), menuBarViewModel: viewModel)
                .frame(minWidth: 700, minHeight: 500)
        }
        .sheet(isPresented: $viewModel.showPresetsWindow) {
            PresetManagementView(menuBarViewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSettingsWindow) {
            SettingsView(menuBarViewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showResumeSheet) {
            if let snapshot = viewModel.lastSnapshot {
                ResumeSessionSheet(
                    viewModel: ResumeSessionViewModel(snapshot: snapshot),
                    menuBarViewModel: viewModel
                )
                .frame(minWidth: 560, minHeight: 380)
            } else {
                Text("No snapshot available")
                    .padding()
            }
        }
    }
}
