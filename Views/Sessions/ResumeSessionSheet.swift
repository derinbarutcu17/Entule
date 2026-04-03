import SwiftUI

struct ResumeSessionSheet: View {
    @StateObject var viewModel: ResumeSessionViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    var onClose: (() -> Void)? = nil

    @State private var running = false

    private let metricColumns = [
        GridItem(.adaptive(minimum: 110), spacing: AppWindowMetrics.spacingS)
    ]

    var body: some View {
        AppPaneContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: AppWindowMetrics.spacingM) {
                    Text("Created \(viewModel.snapshot.createdAt.formatted()) • \(viewModel.snapshot.items.count) items")
                        .font(EntuleTypography.font(13, weight: .medium))
                        .foregroundStyle(EntuleTheme.inkDim)

                    if !viewModel.snapshot.note.isEmpty {
                        VStack(alignment: .leading, spacing: AppWindowMetrics.spacingXS) {
                            Text("Saved Note")
                                .font(EntuleTypography.font(18, weight: .semibold))
                                .foregroundStyle(EntuleTheme.ink)
                            Text(viewModel.snapshot.note)
                                .font(EntuleTypography.font(14))
                                .foregroundStyle(EntuleTheme.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .entulePanel()
                    }

                    VStack(alignment: .leading, spacing: AppWindowMetrics.spacingS) {
                        Text("Items")
                            .font(EntuleTypography.font(18, weight: .semibold))
                            .foregroundStyle(EntuleTheme.ink)

                        List(viewModel.snapshot.items) { item in
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
                            .listRowBackground(Color.clear)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listStyle(.plain)
                        .frame(minHeight: AppWindowMetrics.listMinHeight)
                    }
                    .entulePanel()

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

                            if let shortcutResult = report.shortcutResult {
                                let status = shortcutResult.succeeded ? "succeeded" : "failed"
                                Text("Shortcut \"\(shortcutResult.name)\" \(status)")
                                    .font(EntuleTypography.font(12))
                                    .foregroundStyle(EntuleTheme.inkDim)
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
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        } toolbar: {
            Button("Close") { closeView() }
                .buttonStyle(EntuleSecondaryButtonStyle())
                .disabled(running)
            Spacer()
            Button(running ? "Resuming…" : "Resume") {
                Task { await runResume() }
            }
            .buttonStyle(EntulePrimaryButtonStyle())
            .disabled(running)
        }
        .onAppear {
            if viewModel.needsConfirmation {
                viewModel.showConfirmation = true
            }
        }
        .alert("Resume \(viewModel.snapshot.items.count) items?", isPresented: $viewModel.showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Resume") { Task { await runResume() } }
        }
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

    private func closeView() {
        onClose?()
    }
}
