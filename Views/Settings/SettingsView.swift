import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Toggle("Show permissions hint", isOn: $viewModel.showPermissionsHint)

            if viewModel.showPermissionsHint {
                Text(viewModel.permissionsHint)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 420)
    }
}
