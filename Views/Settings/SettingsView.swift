import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    @State private var confirmClearSnapshot = false
    @State private var confirmResetAllState = false

    init(workspaceViewModel: WorkspaceViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(workspaceViewModel: workspaceViewModel))
    }

    var body: some View {
        AppPaneContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Permissions")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        Toggle("Show automation hint", isOn: $viewModel.showPermissionsHint)
                            .foregroundStyle(EntuleTheme.moon)

                        if viewModel.showPermissionsHint {
                            Text(viewModel.permissionsHint)
                                .font(.caption)
                                .foregroundStyle(EntuleTheme.moonDim)
                        }
                    }
                    .entulePanel()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Testing & Storage")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        HStack {
                            Button("Reveal Entule Data Folder") {
                                viewModel.revealDataFolder()
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                            Button("Reveal state.json") {
                                viewModel.revealStateFile()
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        }

                        HStack {
                            Button("Clear Last Snapshot") {
                                confirmClearSnapshot = true
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                            Button("Reset All Local Data", role: .destructive) {
                                confirmResetAllState = true
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        }

                        if !viewModel.feedbackMessage.isEmpty {
                            Text(viewModel.feedbackMessage)
                                .font(.caption)
                                .foregroundStyle(EntuleTheme.moonDim)
                        }
                    }
                    .entulePanel()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Diagnostics")
                            .font(.headline)
                            .foregroundStyle(EntuleTheme.moon)

                        Text(viewModel.diagnosticsText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(EntuleTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: AppWindowMetrics.settingsDiagnosticsHeight, alignment: .topLeading)
                            .textSelection(.enabled)

                        HStack {
                            Button("Refresh Diagnostics") {
                                viewModel.refreshDiagnostics()
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                            Button("Copy Diagnostics") {
                                viewModel.copyDiagnostics()
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        }
                    }
                    .entulePanel()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: AppWindowMetrics.settingsScrollHeight)
        }
        .alert("Clear last snapshot?", isPresented: $confirmClearSnapshot) {
            Button("Cancel", role: .cancel) {}
            Button("Clear") {
                viewModel.clearLastSnapshot()
            }
        } message: {
            Text("This removes only the last saved checkpoint snapshot.")
        }
        .alert("Reset all local Entule data?", isPresented: $confirmResetAllState) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllLocalState()
            }
        } message: {
            Text("This removes presets and snapshots from local storage, then recreates a clean empty state.")
        }
    }
}
