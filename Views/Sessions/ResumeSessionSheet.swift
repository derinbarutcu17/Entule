import SwiftUI

struct ResumeSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ResumeSessionViewModel
    @ObservedObject var menuBarViewModel: MenuBarViewModel

    @State private var running = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Resume Last Session")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(EntuleTheme.moon)
                Text("Created \(viewModel.snapshot.createdAt.formatted()) • \(viewModel.snapshot.items.count) items")
                    .font(.caption)
                    .foregroundStyle(EntuleTheme.moonDim)
            }

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
                HStack {
                    Text(item.kind.rawValue.uppercased())
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                        .foregroundStyle(EntuleTheme.moonDim)
                    Text(item.displayName)
                        .foregroundStyle(EntuleTheme.moon)
                    Spacer()
                    Text(item.value)
                        .foregroundStyle(EntuleTheme.moonDim)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(minHeight: 260)
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

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(EntuleSecondaryButtonStyle())
                    .disabled(running)
                Spacer()
                Button(running ? "Resuming…" : "Resume") {
                    Task {
                        running = true
                        viewModel.lastReport = await menuBarViewModel.resumeLastSnapshot()
                        running = false
                    }
                }
                .buttonStyle(EntulePrimaryButtonStyle())
                .disabled(running)
            }
        }
        .padding()
        .entuleWindowBackground()
        .background(
            WindowAccessor { window in
                WindowCoordinator.activate(window: window)
            }
        )
        .onAppear {
            if viewModel.needsConfirmation {
                viewModel.showConfirmation = true
            }
        }
        .alert("Resume \(viewModel.snapshot.items.count) items?", isPresented: $viewModel.showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Resume") {
                Task {
                    running = true
                    viewModel.lastReport = await menuBarViewModel.resumeLastSnapshot()
                    running = false
                }
            }
        }
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
}
