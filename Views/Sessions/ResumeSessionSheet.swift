import SwiftUI

struct ResumeSessionSheet: View {
    @StateObject var viewModel: ResumeSessionViewModel
    @ObservedObject var workspaceViewModel: WorkspaceViewModel
    var onClose: (() -> Void)? = nil

    @State private var running = false

    var body: some View {
        AppPaneContainer {
            VStack(alignment: .leading, spacing: AppWindowMetrics.sectionSpacing) {
            Text("Created \(viewModel.snapshot.createdAt.formatted()) • \(viewModel.snapshot.items.count) items")
                .font(.caption)
                .foregroundStyle(EntuleTheme.moonDim)

            if !viewModel.snapshot.note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Saved Note")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)
                    Text(viewModel.snapshot.note)
                        .foregroundStyle(EntuleTheme.moon)
                }
                .entulePanel()
            }

            List(viewModel.snapshot.items) { item in
                HStack(spacing: 8) {
                    Text(item.kind.rawValue.uppercased())
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                        .foregroundStyle(EntuleTheme.moonDim)
                    Text(item.displayName)
                        .foregroundStyle(EntuleTheme.moon)
                    Spacer(minLength: 8)
                    Text(item.value)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(EntuleTheme.moonDim)
                    CopyValueButton(value: item.value, label: item.displayName)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(height: AppWindowMetrics.resumeContentHeight)
            .entulePanel()

            if let report = viewModel.lastReport {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Resume Result")
                        .font(.headline)
                        .foregroundStyle(EntuleTheme.moon)

                    HStack(spacing: 10) {
                        metricPill("Attempted", value: report.attemptedCount, tint: EntuleTheme.moonDim)
                        metricPill("Succeeded", value: report.succeededCount, tint: EntuleTheme.success)
                        metricPill("Failed", value: report.failedCount, tint: EntuleTheme.danger)
                        metricPill("Skipped", value: report.skippedCount, tint: EntuleTheme.amber)
                    }

                    if let shortcutResult = report.shortcutResult {
                        let status = shortcutResult.succeeded ? "succeeded" : "failed"
                        Text("Shortcut \"\(shortcutResult.name)\" \(status)")
                            .font(.caption)
                            .foregroundStyle(EntuleTheme.moonDim)
                    }

                    if report.failures.isEmpty {
                        Text("No failed items.")
                            .font(.caption)
                            .foregroundStyle(EntuleTheme.moonDim)
                    } else {
                        ForEach(report.failures.prefix(5), id: \.item.id) { failure in
                            Text("• \(failure.item.displayName): \(failure.reason)")
                                .font(.caption)
                                .foregroundStyle(EntuleTheme.moonDim)
                        }
                    }
                }
                .entulePanel()
            }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
            Button("Resume") {
                Task { await runResume() }
            }
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
                .font(.caption2)
                .foregroundStyle(tint)
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(EntuleTheme.moon)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.04))
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
