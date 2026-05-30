import Cocoa
import SwiftUI

enum Preferences {
    static let thresholdKey = "overlayThreshold"
    static let maxIntensityKey = "maxIntensity"
    static let defaultThreshold = 20
    static let defaultMaxIntensity = 30
}

class PreferencesWindowController: NSWindowController, NSWindowDelegate {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 260),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Preferences"
        window.contentView = NSHostingView(rootView: PreferencesView())
        window.center()
        window.isReleasedWhenClosed = false
        self.init(window: window)
    }
}

struct PreferencesView: View {
    @AppStorage(Preferences.thresholdKey) private var threshold = Preferences.defaultThreshold
    @AppStorage(Preferences.maxIntensityKey) private var maxIntensity = Preferences.defaultMaxIntensity

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Red Eye Overlay", systemImage: "eye.fill")
                        .font(.headline)

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Activate below")
                            Text("Battery percentage to begin the overlay")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Picker("Activate below", selection: $threshold) {
                            ForEach([5, 10, 15, 20, 25, 30, 40], id: \.self) { v in
                                Text("\(v)%").tag(v)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Max intensity")
                            Text("Overlay opacity when battery reaches 0%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Picker("Max intensity", selection: $maxIntensity) {
                            ForEach([10, 20, 30, 40, 50], id: \.self) { v in
                                Text("\(v)%").tag(v)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 80)
                    }
                }
                .padding(4)
            }
        }
        .padding(24)
        .frame(width: 400, height: 240)
    }
}
