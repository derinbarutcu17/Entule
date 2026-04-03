import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var appShellViewModel: AppShellViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    @State private var hoveredSection: AppSection?

    var body: some View {
        HStack(spacing: AppWindowMetrics.shellSpacing) {
            sidebar

            Divider()
                .overlay(EntuleTheme.lineSoft)

            VStack(alignment: .leading, spacing: AppWindowMetrics.sectionSpacing) {
                header
                activeSectionView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(.top, AppWindowMetrics.titlebarTopInset)
        .padding(.horizontal, AppWindowMetrics.shellPadding)
        .padding(.bottom, AppWindowMetrics.shellPadding)
        .frame(width: AppWindowMetrics.primaryWindowWidth, height: AppWindowMetrics.primaryWindowHeight)
        .entuleWindowBackground()
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.sectionSpacing) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ENTULE")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2.8)
                    .foregroundStyle(EntuleTheme.amber)
                Text("Return to work instantly.")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(EntuleTheme.moon)
                Text("This is the main app surface. Use it like a regular desktop app, with the menu bar as quick access.")
                    .font(.system(size: 13))
                    .foregroundStyle(EntuleTheme.moonDim)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(AppSection.allCases) { section in
                    SidebarNavItem(
                        section: section,
                        isActive: appShellViewModel.activeSection == section,
                        isHovered: hoveredSection == section,
                        action: { appShellViewModel.navigate(to: section) },
                        onHover: { isHovering in
                            hoveredSection = isHovering ? section : (hoveredSection == section ? nil : hoveredSection)
                        }
                    )
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 10) {
                Text("Status")
                    .font(.headline)
                    .foregroundStyle(EntuleTheme.moon)
                Text(appShellViewModel.statusLine)
                    .font(.system(size: 13))
                    .foregroundStyle(EntuleTheme.moonDim)

                HStack(spacing: 10) {
                    statChip(label: "Presets", value: workspaceViewModel.presets.count)
                    statChip(label: "Saved", value: workspaceViewModel.lastSnapshot?.items.count ?? 0)
                }
            }
            .entulePanel()
        }
        .frame(minWidth: AppWindowMetrics.sidebarWidth, maxWidth: AppWindowMetrics.sidebarWidth, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(appShellViewModel.activeSection.title)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(EntuleTheme.moon)
            Text(appShellViewModel.activeSection.subtitle)
                .font(.system(size: 14))
                .foregroundStyle(EntuleTheme.moonDim)
        }
    }

    @ViewBuilder
    private var activeSectionView: some View {
        switch appShellViewModel.activeSection {
        case .home:
            homeSection
        case .saveSession:
            SaveSessionSheet(
                viewModel: SaveSessionViewModel(),
                workspaceViewModel: workspaceViewModel,
                onClose: { appShellViewModel.showHome() }
            )
        case .inspectCheckpoint:
            if let snapshot = workspaceViewModel.lastSnapshot {
                ResumeSessionSheet(
                    viewModel: ResumeSessionViewModel(snapshot: snapshot),
                    workspaceViewModel: workspaceViewModel,
                    onClose: { appShellViewModel.showHome() }
                )
            } else {
                emptyState(
                    title: "No checkpoint saved yet",
                    message: "Save a current session first, then come back here to resume it."
                )
            }
        case .presets:
            PresetManagementView(workspaceViewModel: workspaceViewModel)
        case .settings:
            SettingsView(workspaceViewModel: workspaceViewModel)
        }
    }

    private var homeSection: some View {
        VStack(spacing: AppWindowMetrics.sectionSpacing) {
            HStack(spacing: AppWindowMetrics.sectionSpacing) {
                ForEach(homeActionCards) { card in
                    ActionCardButton(
                        title: card.title,
                        detail: card.detail,
                        actionTitle: card.actionTitle,
                        isPrimary: card.isPrimary,
                        isDisabled: card.isDisabled,
                        action: card.action,
                        height: AppWindowMetrics.homeActionCardHeight
                    )
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: AppWindowMetrics.sectionSpacing) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Last Checkpoint")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    if let snapshot = workspaceViewModel.lastSnapshot {
                        checkpointStatRow(label: "Created", value: snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))
                        checkpointStatRow(label: "Items", value: "\(snapshot.items.count)")
                        checkpointStatRow(label: "Shortcut", value: snapshot.shortcutName ?? "None")

                        if !snapshot.note.isEmpty {
                            Text(snapshot.note)
                                .font(.callout)
                                .foregroundStyle(EntuleTheme.moon)
                                .padding(.top, 4)
                        }

                        HStack(spacing: 10) {
                            Button("Resume") {
                                Task { _ = await workspaceViewModel.resumeLastSnapshot() }
                            }
                            .buttonStyle(EntulePrimaryButtonStyle())
                            .disabled(!workspaceViewModel.canResumeLastSession)

                            Button("Inspect") {
                                appShellViewModel.inspectCheckpoint()
                            }
                            .buttonStyle(EntuleSecondaryButtonStyle())
                        }
                        .padding(.top, 6)
                    } else {
                        emptyStateInline("No checkpoint saved yet.")
                    }
                }
                .frame(maxWidth: .infinity, minHeight: AppWindowMetrics.homeLowerPanelHeight, maxHeight: AppWindowMetrics.homeLowerPanelHeight, alignment: .topLeading)
                .entulePanel()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Presets")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    if workspaceViewModel.presets.isEmpty {
                        emptyStateInline("No presets yet. Create one to open apps, folders, files, and URLs in one click.")
                    } else {
                        ForEach(workspaceViewModel.presets.prefix(5)) { preset in
                            HStack(alignment: .center, spacing: 12) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(preset.name)
                                        .foregroundStyle(EntuleTheme.moon)
                                    Text("\(preset.items.count) items")
                                        .font(.caption)
                                        .foregroundStyle(EntuleTheme.moonDim)
                                }
                                Spacer()
                                Button("Launch") {
                                    Task { await workspaceViewModel.launchPreset(preset) }
                                }
                                .buttonStyle(EntuleSecondaryButtonStyle())
                                .disabled(workspaceViewModel.isBusy)
                            }
                            if preset.id != workspaceViewModel.presets.prefix(5).last?.id {
                                Divider().overlay(EntuleTheme.lineSoft)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, minHeight: AppWindowMetrics.homeLowerPanelHeight, maxHeight: AppWindowMetrics.homeLowerPanelHeight, alignment: .topLeading)
                .entulePanel()
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var homeActionCards: [HomeActionCard] {
        [
            HomeActionCard(
                id: "save-current-session",
                title: "Save Current Session",
                detail: "Detect open work, review it, and save a checkpoint.",
                actionTitle: "Save Now",
                isPrimary: true,
                isDisabled: workspaceViewModel.isBusy,
                action: { appShellViewModel.showSaveSession() }
            ),
            HomeActionCard(
                id: "resume-last-session",
                title: "Resume Last Session",
                detail: "Reopen your latest checkpoint with the saved note and resources.",
                actionTitle: "Resume",
                isPrimary: false,
                isDisabled: !workspaceViewModel.canResumeLastSession,
                action: { Task { _ = await workspaceViewModel.resumeLastSnapshot() } }
            ),
            HomeActionCard(
                id: "manage-presets",
                title: "Manage Presets",
                detail: "Create reusable launch sets for the work you repeat often.",
                actionTitle: "Open Presets",
                isPrimary: false,
                isDisabled: false,
                action: { appShellViewModel.openPresets() }
            )
        ]
    }

    private func checkpointStatRow(label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .foregroundStyle(EntuleTheme.moonDim)
            Spacer(minLength: 8)
            Text(value)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(EntuleTheme.moon)
            CopyValueButton(value: value, label: label)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statChip(label: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(EntuleTheme.moonDim)
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(EntuleTheme.moon)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(EntuleTheme.lineSoft, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(EntuleTheme.moon)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(EntuleTheme.moonDim)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private func emptyStateInline(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 13))
            .foregroundStyle(EntuleTheme.moonDim)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct HomeActionCard: Identifiable {
    let id: String
    let title: String
    let detail: String
    let actionTitle: String
    let isPrimary: Bool
    let isDisabled: Bool
    let action: () -> Void
}
