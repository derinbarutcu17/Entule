import SwiftUI

struct EntuleDashboardView: View {
    @ObservedObject var appShellViewModel: AppShellViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                if appShellViewModel.activeSection == .home {
                    homeScene(in: proxy.size)
                } else {
                    secondaryScene(in: proxy.size)
                }
            }
            .padding(.top, AppWindowMetrics.titlebarTopInset)
            .padding(.horizontal, AppWindowMetrics.outerPadding)
            .padding(.bottom, AppWindowMetrics.outerPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .entuleWindowBackground()
    }

    private func homeScene(in size: CGSize) -> some View {
        let compact = size.width < 1040 || size.height < 720
        let saveSize = clamp(size.width * (compact ? 0.34 : 0.40), min: AppWindowMetrics.homeSaveMin, max: AppWindowMetrics.homeSaveMax)
        let resumeSize = clamp(size.width * (compact ? 0.22 : 0.24), min: AppWindowMetrics.homeResumeMin, max: AppWindowMetrics.homeResumeMax)
        let inspectSize = clamp(size.width * 0.1, min: AppWindowMetrics.homeInspectMin, max: AppWindowMetrics.homeInspectMax)
        let previewWidth = clamp(size.width * 0.17, min: AppWindowMetrics.homePreviewMinWidth, max: AppWindowMetrics.homePreviewMaxWidth)

        return VStack(alignment: .leading, spacing: AppWindowMetrics.spacingL) {
            Text("Entule")
                .font(EntuleTypography.font(compact ? 48 : 62, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)

            if compact {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingL) {
                        homeSaveOrb(size: saveSize)
                            .frame(maxWidth: .infinity, alignment: .center)

                        HStack(alignment: .top, spacing: AppWindowMetrics.spacingM) {
                            homeResumeOrb(size: resumeSize)
                            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                                inspectOrb(size: inspectSize)
                                previewCard(width: previewWidth)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.trailing, 104)
                }
            } else {
                HStack(alignment: .top, spacing: AppWindowMetrics.spacingXL) {
                    homeSaveOrb(size: saveSize)
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                        HStack(alignment: .top, spacing: AppWindowMetrics.spacingM) {
                            homeResumeOrb(size: resumeSize)
                            previewCard(width: previewWidth)
                        }
                        inspectOrb(size: inspectSize)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.trailing, 104)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay(alignment: .bottomTrailing) {
            floatingUtilities
                .padding(.trailing, AppWindowMetrics.spacingXS)
                .padding(.bottom, AppWindowMetrics.spacingXS)
        }
    }

    private func secondaryScene(in size: CGSize) -> some View {
        let compact = size.width < 1080
        return HStack(alignment: .top, spacing: AppWindowMetrics.spacingXL) {
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingL) {
                Text("Entule")
                    .font(EntuleTypography.font(compact ? 42 : 56, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)

                if compact {
                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingL) {
                        secondaryHero(width: size.width - 2 * AppWindowMetrics.outerPadding - 100)
                        activeSectionPage
                    }
                } else {
                    HStack(alignment: .top, spacing: AppWindowMetrics.spacingXL) {
                        secondaryHero(width: clamp(size.width * 0.24, min: AppWindowMetrics.heroMinWidth, max: AppWindowMetrics.heroMaxWidth))
                        activeSectionPage
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .overlay(alignment: .bottomTrailing) {
            floatingDock
                .padding(.trailing, AppWindowMetrics.spacingXS)
                .padding(.bottom, AppWindowMetrics.spacingXS)
        }
    }

    private var activeSectionPage: some View {
        Group {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func homeSaveOrb(size: CGFloat) -> some View {
        orbButton(
            title: "Save\nSession",
            size: size,
            detail: lastSaveLabel,
            detailRotation: -18,
            action: { appShellViewModel.showSaveSession() },
            disabled: workspaceViewModel.isBusy,
            fontSize: size > 360 ? 68 : 52,
            centered: true
        )
    }

    private func homeResumeOrb(size: CGFloat) -> some View {
        orbButton(
            title: "Resume\nSession",
            size: size,
            detail: nil,
            detailRotation: 0,
            action: { Task { _ = await workspaceViewModel.resumeLastSnapshot() } },
            disabled: !workspaceViewModel.canResumeLastSession,
            fontSize: size > 240 ? 38 : 30,
            centered: false
        )
    }

    private func inspectOrb(size: CGFloat) -> some View {
        orbButton(
            title: inspectLabel,
            size: size,
            detail: nil,
            detailRotation: 0,
            action: { appShellViewModel.inspectCheckpoint() },
            disabled: workspaceViewModel.lastSnapshot == nil,
            fontSize: size > 100 ? 18 : 15,
            centered: true
        )
    }

    private func previewCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if previewItems.isEmpty {
                Text("No saved\nitems yet")
                    .font(EntuleTypography.font(17, weight: .medium))
                    .foregroundStyle(Color.white)
            } else {
                ForEach(previewItems, id: \.self) { item in
                    Text("• \(item)")
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .font(EntuleTypography.font(16))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding(.horizontal, AppWindowMetrics.panelPadding)
        .padding(.vertical, AppWindowMetrics.panelPadding)
        .frame(width: width, alignment: .topLeading)
        .frame(minHeight: AppWindowMetrics.homePreviewHeight, alignment: .topLeading)
        .background(EntuleTheme.primaryButtonGradient)
        .clipShape(RoundedRectangle(cornerRadius: AppWindowMetrics.panelCornerRadius, style: .continuous))
        .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 12, y: 8)
    }

    private func secondaryHero(width: CGFloat) -> some View {
        let circleSize = clamp(width * 0.9, min: AppWindowMetrics.heroCircleMin, max: AppWindowMetrics.heroCircleMax)
        let metaSize = clamp(width * 0.4, min: AppWindowMetrics.heroMetaMin, max: AppWindowMetrics.heroMetaMax)

        return VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: circleSize, height: circleSize)
                .overlay(alignment: .leading) {
                    Text(heroTitle(for: appShellViewModel.activeSection))
                        .font(EntuleTypography.font(circleSize > 220 ? 40 : 32, weight: .medium))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.white)
                        .padding(circleSize * 0.18)
                }

            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: metaSize, height: metaSize)
                .overlay {
                    Text(metaLabel(for: appShellViewModel.activeSection))
                        .font(EntuleTypography.font(15, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white)
                        .padding(10)
                }

            Text(descriptionText(for: appShellViewModel.activeSection))
                .font(EntuleTypography.font(14))
                .foregroundStyle(EntuleTheme.inkDim)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width, alignment: .topLeading)
    }

    private var floatingDock: some View {
        VStack(alignment: .trailing, spacing: AppWindowMetrics.floatingDockSpacing) {
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
    }

    private var floatingUtilities: some View {
        VStack(spacing: AppWindowMetrics.floatingDockSpacing) {
            HomeUtilityButton(
                width: AppWindowMetrics.floatingDockCircleSize + 24,
                height: AppWindowMetrics.floatingDockCircleSize + 24,
                action: { appShellViewModel.openSettings() }
            ) {
                Image(systemName: "gearshape")
                    .font(.system(size: 28, weight: .regular))
            }

            HomeUtilityButton(
                width: 104,
                height: 86,
                action: { appShellViewModel.openPresets() }
            ) {
                VStack(spacing: 4) {
                    Text("Presets")
                        .font(EntuleTypography.font(17, weight: .medium))
                    Image(systemName: "plus.square.on.square")
                        .font(.system(size: 18, weight: .regular))
                }
            }
        }
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
                        .font(EntuleTypography.font(fontSize, weight: .medium))
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
                            .padding(.leading, size * 0.18)
                            .padding(.bottom, size * 0.08)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
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
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
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

    private func clamp(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        Swift.max(minValue, Swift.min(maxValue, value))
    }
}
