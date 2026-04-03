import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var appShellViewModel: AppShellViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / AppWindowMetrics.primaryWindowWidth,
                proxy.size.height / AppWindowMetrics.primaryWindowHeight
            )

            ZStack {
                ZStack(alignment: .bottomTrailing) {
                    if appShellViewModel.activeSection == .home {
                        homeScene
                    } else {
                        secondaryScene
                    }
                }
                .frame(width: AppWindowMetrics.primaryWindowWidth, height: AppWindowMetrics.primaryWindowHeight)
                .scaleEffect(scale, anchor: .center)
            }
        }
        .entuleWindowBackground()
    }

    private var homeScene: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Text("Entule")
                    .font(EntuleTypography.font(62))
                    .foregroundStyle(EntuleTheme.ink)
                    .padding(.top, AppWindowMetrics.titlebarTopInset)
                    .padding(.leading, 20)

                orbButton(
                    title: "Save\nSession",
                    size: AppWindowMetrics.homeSaveCircleSize,
                    detail: lastSaveLabel,
                    detailRotation: -18,
                    action: { appShellViewModel.showSaveSession() },
                    disabled: workspaceViewModel.isBusy,
                    fontSize: 72,
                    centered: true
                )
                .position(x: 330, y: 405)

                orbButton(
                    title: "Resume\nSession",
                    size: AppWindowMetrics.homeResumeCircleSize,
                    detail: nil,
                    detailRotation: 0,
                    action: { Task { _ = await workspaceViewModel.resumeLastSnapshot() } },
                    disabled: !workspaceViewModel.canResumeLastSession,
                    fontSize: 42,
                    centered: false
                )
                .position(x: 700, y: 230)

                previewCard
                    .position(x: 940, y: 245)

                orbButton(
                    title: inspectLabel,
                    size: AppWindowMetrics.homeInspectCircleSize,
                    detail: nil,
                    detailRotation: 0,
                    action: { appShellViewModel.inspectCheckpoint() },
                    disabled: workspaceViewModel.lastSnapshot == nil,
                    fontSize: 19,
                    centered: true
                )
                .position(x: 810, y: 405)

                VStack(spacing: 14) {
                    HomeUtilityButton(
                        width: AppWindowMetrics.homeUtilityCircleSize,
                        height: AppWindowMetrics.homeUtilityCircleSize,
                        action: { appShellViewModel.openSettings() }
                    ) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 30, weight: .regular))
                    }

                    HomeUtilityButton(
                        width: AppWindowMetrics.homeUtilityPillWidth,
                        height: AppWindowMetrics.homeUtilityPillHeight,
                        action: { appShellViewModel.openPresets() }
                    ) {
                        VStack(spacing: 4) {
                            Text("Presets")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                            Image(systemName: "plus.square.on.square")
                                .font(.system(size: 18, weight: .regular))
                        }
                    }
                }
                .position(x: proxy.size.width - 72, y: proxy.size.height - 110)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var secondaryScene: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 26) {
                Text("Entule")
                    .font(EntuleTypography.font(58))
                    .foregroundStyle(EntuleTheme.ink)

                HStack(alignment: .top, spacing: 34) {
                    secondaryHero
                        .frame(width: 280)

                    activeSectionPage
                        .frame(width: AppWindowMetrics.sectionContentWidth)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .padding(.top, AppWindowMetrics.titlebarTopInset + 6)
            .padding(.leading, 20)
            .padding(.bottom, 20)
            .padding(.trailing, 116)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            VStack(alignment: .trailing, spacing: AppWindowMetrics.floatingDockStackSpacing) {
                ForEach(AppSection.allCases.filter { $0 != .home }) { section in
                    FloatingSectionButton(
                        section: section,
                        isActive: appShellViewModel.activeSection == section,
                        action: { appShellViewModel.navigate(to: section) }
                    )
                }

                FloatingSectionButton(section: .home, isActive: false) {
                    appShellViewModel.showHome()
                }
            }
            .padding(.trailing, 18)
            .padding(.bottom, 18)
        }
    }

    private var secondaryHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: AppWindowMetrics.sectionHeroSize, height: AppWindowMetrics.sectionHeroSize)
                .overlay(
                    Text(heroTitle(for: appShellViewModel.activeSection))
                        .font(EntuleTypography.font(44))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.white)
                        .padding(38),
                    alignment: .leading
                )

            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: AppWindowMetrics.sectionMetaCircleSize, height: AppWindowMetrics.sectionMetaCircleSize)
                .overlay(
                    Text(metaLabel(for: appShellViewModel.activeSection))
                        .font(EntuleTypography.font(16, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .padding(10)
                )

            Text(descriptionText(for: appShellViewModel.activeSection))
                .font(EntuleTypography.font(14))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var activeSectionPage: some View {
        switch appShellViewModel.activeSection {
        case .home:
            EmptyView()
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
                    message: "Save a session first, then come back here to inspect it or resume it."
                )
            }
        case .presets:
            PresetManagementView(workspaceViewModel: workspaceViewModel)
        case .settings:
            SettingsView(workspaceViewModel: workspaceViewModel)
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            if previewItems.isEmpty {
                Text("No saved\nitems yet")
                    .font(EntuleTypography.font(17, weight: .medium))
                    .foregroundStyle(Color.white)
            } else {
                ForEach(previewItems, id: \.self) { item in
                    Text("• \(item)")
                        .lineLimit(1)
                        .font(EntuleTypography.font(16))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 20)
        .frame(width: AppWindowMetrics.homePreviewWidth, height: AppWindowMetrics.homePreviewHeight, alignment: .topLeading)
        .background(EntuleTheme.primaryButtonGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 12, y: 8)
    }

    private var previewItems: [String] {
        guard let snapshot = workspaceViewModel.lastSnapshot else { return [] }
        return Array(snapshot.items.prefix(7).map(\.displayName))
    }

    private var lastSaveLabel: String {
        guard let snapshot = workspaceViewModel.lastSnapshot else {
            return "save a checkpoint"
        }
        return "last save: \(snapshot.createdAt.formatted(date: .abbreviated, time: .shortened))"
    }

    private var inspectLabel: String {
        let count = workspaceViewModel.lastSnapshot?.items.count ?? 0
        return count == 1 ? "1 Item" : "\(count) Items"
    }

    private func orbButton(
        title: String,
        size: CGFloat,
        detail: String?,
        detailRotation: Double,
        action: @escaping () -> Void,
        disabled: Bool,
        fontSize: CGFloat,
        centered: Bool
    ) -> some View {
        Button(action: action) {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: size, height: size)
                .overlay(alignment: centered ? .center : .leading) {
                    Text(title)
                        .font(EntuleTypography.font(fontSize))
                        .multilineTextAlignment(centered ? .center : .leading)
                        .foregroundStyle(Color.white)
                        .padding(centered ? 0 : size * 0.18)
                }
                .overlay(alignment: .bottomLeading) {
                    if let detail {
                        Text(detail)
                            .font(EntuleTypography.font(size > 300 ? 21 : 15))
                            .foregroundStyle(Color.white)
                            .rotationEffect(.degrees(detailRotation))
                            .padding(.leading, size * 0.2)
                            .padding(.bottom, size * 0.08)
                    }
                }
                .opacity(disabled ? 0.45 : 1)
                .shadow(color: EntuleTheme.orange.opacity(disabled ? 0.08 : 0.18), radius: 16, y: 10)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private func heroTitle(for section: AppSection) -> String {
        switch section {
        case .home:
            return ""
        case .saveSession:
            return "Save\nSession"
        case .inspectCheckpoint:
            return "Inspect\nSession"
        case .presets:
            return "Preset\nLibrary"
        case .settings:
            return "Settings"
        }
    }

    private func metaLabel(for section: AppSection) -> String {
        switch section {
        case .home:
            return ""
        case .saveSession:
            return workspaceViewModel.lastSnapshot == nil ? "new" : "review"
        case .inspectCheckpoint:
            return inspectLabel
        case .presets:
            let count = workspaceViewModel.presets.count
            return count == 1 ? "1 set" : "\(count) sets"
        case .settings:
            return "local\ncontrols"
        }
    }

    private func descriptionText(for section: AppSection) -> String {
        switch section {
        case .home:
            return ""
        case .saveSession:
            return "Capture the apps, folders, files, and links you want to reopen later, then trim the list before saving."
        case .inspectCheckpoint:
            return "Review the latest checkpoint, read its note, and see exactly what Entule will try to reopen."
        case .presets:
            return "Build reusable launch sets for the work you repeat often and run them whenever you need them."
        case .settings:
            return "Permissions, local storage controls, reset tools, and lightweight diagnostics all live here."
        }
    }

    private func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(EntuleTypography.font(24, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
            Text(message)
                .font(EntuleTypography.font(14))
                .foregroundStyle(EntuleTheme.inkDim)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }
}
