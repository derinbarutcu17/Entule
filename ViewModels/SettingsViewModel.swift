import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showPermissionsHint: Bool = true

    var permissionsHint: String {
        PermissionsHelper.appleEventsHelpText()
    }
}
