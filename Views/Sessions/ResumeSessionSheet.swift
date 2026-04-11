import SwiftUI

struct ResumeSessionSheet: View {
    @StateObject var viewModel: ResumeSessionViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel

    @State private var running = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 110), spacing: AppWindowMetrics.spacingS)
    ]
    private let resumeButtonDiameter: CGFloat = 112
    private let rowHeightEstimate: CGFloat = 56
    private let listTopOffsetEstimate: CGFloat = 58
    private let curveSafetyGap: CGFloat = 12

    var body: some View {
        AppPaneContainer {
            VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                itemsPanel

                if let report = viewModel.lastReport {
                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                        Text("Resume Result")
                            .font(EntuleTypography.font(18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.ink)

                        LazyVGrid(columns: metricColumns, alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                            metricPill("Attempted", value: report.attemptedCount, tint: EntuleTheme.inkDim)
                            metricPill("Succeeded", value: report.succeededCount, tint: EntuleTheme.success)
                            metricPill("Failed", value: report.failedCount, tint: EntuleTheme.danger)
                            metricPill("Skipped", value: report.skippedCount, tint: EntuleTheme.amber)
                        }

                        if report.failures.isEmpty {
                            Text("No failed items.")
                                .font(EntuleTypography.font(12))
                                .foregroundStyle(EntuleTheme.inkDim)
                        } else {
                            ForEach(report.failures.prefix(5), id: \.item.id) { failure in
                                Text("• \(failure.item.displayName): \(failure.reason)")
                                    .font(EntuleTypography.font(12))
                                    .foregroundStyle(EntuleTheme.inkDim)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .entulePanel()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var itemsPanel: some View {
        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
            Text("Created \(viewModel.snapshot.createdAt.formatted()) • \(viewModel.snapshot.items.count) items")
                .font(EntuleTypography.font(13, weight: .medium))
                .foregroundStyle(EntuleTheme.inkDim)
                .padding(.trailing, 132)

            if viewModel.snapshot.hasUserProvidedName {
                Text("Session: \(sessionName)")
                    .font(EntuleTypography.font(13, weight: .semibold))
                    .foregroundStyle(EntuleTheme.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.trailing, 132)
            }

            Text("Items")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
                .padding(.trailing, 132)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(viewModel.snapshot.items.enumerated()), id: \.element.id) { index, item in
                        let rowInset = curvedTrailingInset(forRowAt: index)
                        VStack(alignment: .leading, spacing: 0) {
                            itemRow(item)
                                .padding(.trailing, rowInset)
                                .padding(.vertical, 8)

                            Divider()
                                .overlay(EntuleTheme.lineSoft)
                                .padding(.trailing, rowInset)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(minHeight: AppWindowMetrics.listMinHeight, maxHeight: .infinity)
        }
        .overlay(alignment: .topTrailing) {
            resumeOrb
                .tutorialAnchor(.resume)
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .entulePanel()
    }

    private func runResume() async {
        guard !running else { return }
        running = true
        defer { running = false }
        viewModel.lastReport = await workspaceViewModel.resumeLastSnapshot()
    }

    private func metricPill(_ label: String, value: Int, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(EntuleTypography.font(11, weight: .semibold))
                .foregroundStyle(tint)
            Text("\(value)")
                .font(EntuleTypography.font(18, weight: .semibold))
                .foregroundStyle(EntuleTheme.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func itemRow(_ item: SessionItem) -> some View {
        HStack(alignment: .top, spacing: AppWindowMetrics.spacingS) {
            Text(item.kind.rawValue.uppercased())
                .font(EntuleTypography.font(11, weight: .semibold))
                .foregroundStyle(EntuleTheme.inkDim)
                .frame(minWidth: AppWindowMetrics.sessionKindMinWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(EntuleTypography.font(14, weight: .medium))
                    .foregroundStyle(EntuleTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.value)
                    .font(EntuleTypography.font(12))
                    .foregroundStyle(EntuleTheme.inkDim)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
            CopyValueButton(value: item.value, label: item.displayName)
        }
    }

    // Computes how much horizontal room to reserve for the top-right resume orb.
    // This is geometry-based (circle intersection), so it naturally relaxes by row ~3.
    private func curvedTrailingInset(forRowAt index: Int) -> CGFloat {
        let radius = resumeButtonDiameter / 2
        let centerY = radius
        let rowCenterY = listTopOffsetEstimate + (CGFloat(index) * rowHeightEstimate) + (rowHeightEstimate / 2)
        let distance = abs(rowCenterY - centerY)

        guard distance < radius else { return 0 }

        let horizontalReach = sqrt(max(0, (radius * radius) - (distance * distance)))
        let inset = radius + horizontalReach + curveSafetyGap
        return min(max(inset, 0), resumeButtonDiameter + curveSafetyGap)
    }

    private var resumeOrb: some View {
        Button {
            Task { await runResume() }
        } label: {
            Circle()
                .fill(EntuleTheme.primaryButtonGradient)
                .frame(width: 112, height: 112)
                .overlay {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 22, weight: .semibold))
                        Text(running ? "Resuming" : "Resume")
                            .font(EntuleTypography.font(15, weight: .bold))
                    }
                    .foregroundStyle(Color.white)
                }
                .shadow(color: EntuleTheme.orange.opacity(0.18), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(running)
        .accessibilityLabel("Resume Session")
    }

    private var sessionName: String {
        let trimmed = viewModel.snapshot.note.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled session" : trimmed
    }
}
