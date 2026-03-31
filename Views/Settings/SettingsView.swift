import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    @State private var confirmClearSnapshot = false
    @State private var confirmResetAllState = false

    init(menuBarViewModel: MenuBarViewModel) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(menuBarViewModel: menuBarViewModel))
    }

    var body: some View {
        Form {
            Section("Permissions") {
                Toggle("Show automation hint", isOn: $viewModel.showPermissionsHint)

                if viewModel.showPermissionsHint {
                    Text(viewModel.permissionsHint)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Testing & Storage") {
                Button("Reveal Entule Data Folder") {
                    viewModel.revealDataFolder()
                }

                Button("Reveal state.json") {
                    viewModel.revealStateFile()
                }

                Button("Clear Last Snapshot") {
                    confirmClearSnapshot = true
                }

                Button("Reset All Local Data", role: .destructive) {
                    confirmResetAllState = true
                }

                if !viewModel.feedbackMessage.isEmpty {
                    Text(viewModel.feedbackMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Diagnostics") {
                ScrollView {
                    Text(viewModel.diagnosticsText)
                        .font(.system(.caption, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 140)

                HStack {
                    Button("Refresh Diagnostics") {
                        viewModel.refreshDiagnostics()
                    }
                    Button("Copy Diagnostics") {
                        viewModel.copyDiagnostics()
                    }
                }
            }
        }
        .padding()
        .frame(width: 520)
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
