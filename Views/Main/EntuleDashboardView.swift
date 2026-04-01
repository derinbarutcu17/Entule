import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    var body: some View {
        HStack(spacing: 18) {
            sidebar

            Divider()
                .overlay(EntuleTheme.lineSoft)

            VStack(alignment: .leading, spacing: 18) {
                header
                activeSectionView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(20)
        .frame(minWidth: 1120, minHeight: 760)
        .entuleWindowBackground()
        .background(
            WindowAccessor { window in
                WindowCoordinator.activate(window: window)
            }
        )
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
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
                    Button {
                        menuBarViewModel.navigate(to: section)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: section.symbolName)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(section.title)
                                    .font(.system(size: 13, weight: .semibold))
                                Text(section.subtitle)
                                    .font(.system(size: 11))
                                    .lineLimit(1)
                                    .opacity(0.78)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(menuBarViewModel.activeSection == section ? Color.white.opacity(0.08) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(menuBarViewModel.activeSection == section ? EntuleTheme.lineWarm : Color.clear, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(menuBarViewModel.activeSection == section ? EntuleTheme.moon : EntuleTheme.moonDim)
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 10) {
                Text("Status")
                    .font(.headline)
                    .foregroundStyle(EntuleTheme.moon)
                Text(menuBarViewModel.statusLine)
                    .font(.system(size: 13))
                    .foregroundStyle(EntuleTheme.moonDim)

                HStack(spacing: 10) {
                    statChip(label: "Presets", value: menuBarViewModel.presets.count)
                    statChip(label: "Saved", value: menuBarViewModel.lastSnapshot?.items.count ?? 0)
                }
            }
            .entulePanel()
        }
        .frame(minWidth: 280, maxWidth: 280, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(menuBarViewModel.activeSection.title)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(EntuleTheme.moon)
            Text(menuBarViewModel.activeSection.subtitle)
                .font(.system(size: 14))
                .foregroundStyle(EntuleTheme.moonDim)
        }
    }

    @ViewBuilder
    private var activeSectionView: some View {
        switch menuBarViewModel.activeSection {
        case .home:
            homeSection
        case .saveSession:
            SaveSessionSheet(
                viewModel: SaveSessionViewModel(),
                menuBarViewModel: menuBarViewModel,
                onClose: { menuBarViewModel.showHome() }
            )
        case .resumeSession:
            if let snapshot = menuBarViewModel.lastSnapshot {
                ResumeSessionSheet(
                    viewModel: ResumeSessionViewModel(snapshot: snapshot),
                    menuBarViewModel: menuBarViewModel,
                    onClose: { menuBarViewModel.showHome() }
                )
            } else {
                emptyState(
                    title: "No checkpoint saved yet",
                    message: "Save a current session first, then come back here to resume it."
                )
            }
        case .presets:
            PresetManagementView(menuBarViewModel: menuBarViewModel)
        case .settings:
            SettingsView(menuBarViewModel: menuBarViewModel)
        }
    }

    private var homeSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 18) {
                actionPanel(
                    title: "Save Current Session",
                    detail: "Detect open work, review it, and save a checkpoint.",
                    actionTitle: "Save Now",
                    isPrimary: true,
                    isDisabled: menuBarViewModel.isBusy
                ) {
                    menuBarViewModel.beginSaveSession()
                }

                actionPanel(
                    title: "Resume Last Session",
                    detail: "Reopen your latest checkpoint with the saved note and resources.",
                    actionTitle: "Resume",
                    isPrimary: false,
                    isDisabled: !menuBarViewModel.canResumeLastSession
                ) {
                    menuBarViewModel.beginResumeSession()
                }

                actionPanel(
                    title: "Manage Presets",
                    detail: "Create reusable launch sets for the work you repeat often.",
                    actionTitle: "Open Presets",
                    isPrimary: false,
                    isDisabled: false
                ) {
                    menuBarViewModel.openPresets()
                }
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Last Checkpoint")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    if let snapshot = menuBarViewModel.lastSnapshot {
                        checkpointStatRow(label: "Created", value: snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))
                        checkpointStatRow(label: "Items", value: "\(snapshot.items.count)")
                        checkpointStatRow(label: "Shortcut", value: snapshot.shortcutName ?? "None")

                        if !snapshot.note.isEmpty {
                            Text(snapshot.note)
                                .font(.callout)
                                .foregroundStyle(EntuleTheme.moon)
                                .padding(.top, 4)
                        }
                    } else {
                        emptyStateInline("No checkpoint saved yet.")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .entulePanel()

                VStack(alignment: .leading, spacing: 14) {
                    Text("Presets")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    if menuBarViewModel.presets.isEmpty {
                        emptyStateInline("No presets yet. Create one to open apps, folders, files, and URLs in one click.")
                    } else {
                        ForEach(menuBarViewModel.presets.prefix(5)) { preset in
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
                                    Task { await menuBarViewModel.launchPreset(preset) }
                                }
                                .buttonStyle(EntuleSecondaryButtonStyle())
                                .disabled(menuBarViewModel.isBusy)
                            }
                            if preset.id != menuBarViewModel.presets.prefix(5).last?.id {
                                Divider().overlay(EntuleTheme.lineSoft)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .entulePanel()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func actionPanel(
        title: String,
        detail: String,
        actionTitle: String,
        isPrimary: Bool,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(EntuleTheme.moon)

            Text(detail)
                .font(.system(size: 13))
                .foregroundStyle(EntuleTheme.moonDim)

            Spacer(minLength: 0)

            if isPrimary {
                Button(actionTitle, action: action)
                    .buttonStyle(EntulePrimaryButtonStyle())
                    .disabled(isDisabled)
            } else {
                Button(actionTitle, action: action)
                    .buttonStyle(EntuleSecondaryButtonStyle())
                    .disabled(isDisabled)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 190, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private func checkpointStatRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(EntuleTheme.moonDim)
            Spacer()
            Text(value)
                .foregroundStyle(EntuleTheme.moon)
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
