import Cocoa
import Combine

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private let batteryMonitor = BatteryMonitor()
    private let overlayManager = OverlayManager()
    private var preferencesController: PreferencesWindowController?
    private var cancellables = Set<AnyCancellable>()

    private let batteryMenuItem = NSMenuItem()
    private let overlayMenuItem = NSMenuItem()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        registerDefaults()
        buildStatusItem()

        batteryMonitor.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.apply($0) }
            .store(in: &cancellables)

        batteryMonitor.start()
    }

    // MARK: - Setup

    private func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Preferences.thresholdKey: Preferences.defaultThreshold,
            Preferences.maxIntensityKey: Preferences.defaultMaxIntensity,
        ])
    }

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let btn = statusItem.button {
            btn.image = NSImage(named: "Icon")
            btn.image?.isTemplate = true
            btn.imagePosition = .imageLeft
        }

        batteryMenuItem.isEnabled = false
        overlayMenuItem.isEnabled = false

        let menu = NSMenu()
        menu.addItem(batteryMenuItem)
        menu.addItem(.separator())
        menu.addItem(overlayMenuItem)
        menu.addItem(.separator())

        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(.separator())

        let aboutItem = NSMenuItem(title: "About Redeye", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem(title: "Quit Redeye", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: - Battery Updates

    private func apply(_ state: BatteryState) {
        updateMenuBar(state)
        overlayManager.update(state)
    }

    private func updateMenuBar(_ state: BatteryState) {
        guard let btn = statusItem.button else { return }
        let threshold = UserDefaults.standard.integer(forKey: Preferences.thresholdKey)

        if let pct = state.percentage {
            btn.title = "  \(pct)%"

            var info = "Battery: \(pct)%"
            if state.isCharging {
                info += "  ⚡"
            } else if let mins = state.timeToEmptyMinutes {
                info += "  " + minutesFormatted(mins)
            }
            batteryMenuItem.title = info

            let isActive = pct <= threshold && !state.isCharging
            overlayMenuItem.attributedTitle = statusLabel(
                isActive ? "Red Eye: Active" : "Red Eye: Inactive",
                dotColor: isActive ? .systemRed : .tertiaryLabelColor
            )
        } else {
            btn.title = ""
            batteryMenuItem.title = "Battery: —"
            overlayMenuItem.attributedTitle = statusLabel("Red Eye: Inactive", dotColor: .tertiaryLabelColor)
        }
    }

    private func minutesFormatted(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return h > 0 ? "\(h)h \(m)m remaining" : "\(m)m remaining"
    }

    private func statusLabel(_ text: String, dotColor: NSColor) -> NSAttributedString {
        let s = NSMutableAttributedString(
            string: "● ",
            attributes: [.foregroundColor: dotColor, .font: NSFont.systemFont(ofSize: 10)]
        )
        s.append(NSAttributedString(
            string: text,
            attributes: [.font: NSFont.menuFont(ofSize: 0)]
        ))
        return s
    }

    // MARK: - Actions

    @objc private func openPreferences() {
        if preferencesController == nil {
            preferencesController = PreferencesWindowController()
        }
        preferencesController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }
}
