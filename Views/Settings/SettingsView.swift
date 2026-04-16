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
            settingsScrollContainer
        }
        .alert("Clear your last saved session?", isPresented: $confirmClearSnapshot) {
            Button("Cancel", role: .cancel) {}
            Button("Clear") {
                viewModel.clearLastSnapshot()
            }
        } message: {
            Text("This removes only the most recent checkpoint. Your presets stay untouched.")
        }
        .alert("Reset Entule on this Mac?", isPresented: $confirmResetAllState) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllLocalState()
            }
        } message: {
            Text("This removes your saved presets and checkpoint from this Mac and starts Entule fresh.")
        }
    }

    @ViewBuilder
    private var settingsScrollContainer: some View {
        if #available(macOS 14.0, *) {
            ScrollView {
                settingsContent
            }
            .scrollClipDisabled()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            ScrollView {
                settingsContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingL) {
            accessPanel
            dataPanel
            resetPanel

            if !viewModel.feedbackMessage.isEmpty {
                Text(viewModel.feedbackMessage)
                    .font(EntuleTypography.font(14, weight: .semibold))
                    .foregroundStyle(EntuleTheme.orangeDeep)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var accessPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            Text("Permissions & Access")
                .font(EntuleTypography.font(22, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)

            Text("Entule may need macOS Automation access to detect open tabs in Safari, Chrome, or Dia, and to detect Finder windows accurately.")
                .font(EntuleTypography.font(15, weight: .medium))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.permissionsHint)
                .font(EntuleTypography.font(15))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Button("Request Browser Access") {
                        viewModel.requestBrowserAutomationAccess()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Open Automation Settings") {
                        viewModel.openAutomationSettings()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }

                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    Button("Request Browser Access") {
                        viewModel.requestBrowserAutomationAccess()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Open Automation Settings") {
                        viewModel.openAutomationSettings()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private var dataPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            Text("Your Data")
                .font(EntuleTypography.font(22, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)

            Text(viewModel.dataSummary)
                .font(EntuleTypography.font(15))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            Button("Open Entule Folder") {
                viewModel.revealDataFolder()
            }
            .buttonStyle(EntuleSecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private var resetPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            Text("Reset")
                .font(EntuleTypography.font(22, weight: .bold))
                .foregroundStyle(EntuleTheme.ink)

            Text("Use these only if you want to remove saved information from this Mac.")
                .font(EntuleTypography.font(15))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppWindowMetrics.spacingS) {
                    Button("Clear Last Saved Session") {
                        confirmClearSnapshot = true
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Reset Entule", role: .destructive) {
                        confirmResetAllState = true
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Reset Tutorial") {
                        viewModel.resetTutorial()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                    Button("Clear Last Saved Session") {
                        confirmClearSnapshot = true
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Reset Entule", role: .destructive) {
                        confirmResetAllState = true
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())

                    Button("Reset Tutorial") {
                        viewModel.resetTutorial()
                    }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .entulePanel()
    }
}
