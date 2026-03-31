import SwiftUI

struct SessionActionsView: View {
    let canResume: Bool
    let isBusy: Bool
    let onResume: () -> Void
    let onSave: () -> Void

    var body: some View {
        Button("Resume Last Session", action: onResume)
            .disabled(!canResume || isBusy)

        Button("Save Current Session", action: onSave)
            .disabled(isBusy)
    }
}
