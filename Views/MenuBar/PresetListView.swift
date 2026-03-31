import SwiftUI

struct PresetListView: View {
    let presets: [Preset]
    let isBusy: Bool
    let onLaunch: (Preset) -> Void

    var body: some View {
        Menu("Launch Preset") {
            if presets.isEmpty {
                Text("No Presets Yet")
            } else {
                ForEach(presets) { preset in
                    Button(preset.name) {
                        onLaunch(preset)
                    }
                }
            }
        }
        .disabled(isBusy)
    }
}
