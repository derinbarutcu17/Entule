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
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Permissions")
                            .font(EntuleTypography.font(18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.ink)

                        Toggle("Show automation hint", isOn: $viewModel.showPermissionsHint)
                            .foregroundStyle(EntuleTheme.ink)

                        if viewModel.showPermissionsHint {
                            Text(viewModel.permissionsHint)
                                .font(EntuleTypography.font(13))
                                .foregroundStyle(EntuleTheme.inkDim)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .entulePanel()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Testing & Storage")
                            .font(EntuleTypography.font(18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.ink)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: AppWindowMetrics.spacingS) {
                                storageButtons
                                Spacer(minLength: 0)
                            }
                            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                                storageButtons
                            }
                        }

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: AppWindowMetrics.spacingS) {
                                resetButtons
                                Spacer(minLength: 0)
                            }
                            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                                resetButtons
                            }
                        }

                        if !viewModel.feedbackMessage.isEmpty {
                            Text(viewModel.feedbackMessage)
                                .font(EntuleTypography.font(12))
                                .foregroundStyle(EntuleTheme.inkDim)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .entulePanel()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Diagnostics")
                            .font(EntuleTypography.font(18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.ink)

                        Text(viewModel.diagnosticsText)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(EntuleTheme.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: AppWindowMetrics.diagnosticsMinHeight, alignment: .topLeading)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)

                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: AppWindowMetrics.spacingS) {
                                diagnosticsButtons
                                Spacer(minLength: 0)
                            }
                            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                                diagnosticsButtons
                            }
                        }
                    }
                    .entulePanel()
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

    private var storageButtons: some View {
        Group {
            Button("Reveal Entule Data Folder") {
                viewModel.revealDataFolder()
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
            Button("Reveal state.json") {
                viewModel.revealStateFile()
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }

    private var resetButtons: some View {
        Group {
            Button("Clear Last Snapshot") {
                confirmClearSnapshot = true
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
            Button("Reset All Local Data", role: .destructive) {
                confirmResetAllState = true
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
        }
    }

    private var diagnosticsButtons: some View {
        Group {
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
}
