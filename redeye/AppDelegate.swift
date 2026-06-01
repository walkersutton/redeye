import Cocoa
import Combine
import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let batteryMonitor = BatteryMonitor()
    private let overlayManager = OverlayManager()
    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    private var settingsController: SettingsWindowController?
    private var cancellables = Set<AnyCancellable>()
    private var lowBatteryPreviewTimer: Timer?
    private var lowBatteryPreviewPercentage = 20

    func applicationDidFinishLaunching(_: Notification) {
        let showIcon = UserDefaults.standard.object(forKey: Preferences.showMenuBarIconKey) as? Bool ?? true
        NSApp.setActivationPolicy(showIcon ? .accessory : .regular)
        buildStatusItem()
        statusItem.isVisible = showIcon

        batteryMonitor.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.apply($0) }
            .store(in: &cancellables)

        batteryMonitor.start()
    }

    // MARK: - Setup

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        configureStatusButton()

        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefsItem.target = self

        let aboutItem = NSMenuItem(title: "About redeye", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self

        let menu = NSMenu()
        menu.addItem(prefsItem)
        menu.addItem(.separator())
        menu.addItem(aboutItem)
        menu.addItem(NSMenuItem(title: "Quit redeye", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: - Preferences

    func applyMenuBarVisibility(_ show: Bool) {
        statusItem?.isVisible = show
        NSApp.setActivationPolicy(show ? .accessory : .regular)
    }

    // MARK: - Battery Updates

    private func apply(_ state: BatteryState) {
        overlayManager.update(state)
    }

    private func configureStatusButton() {
        guard let btn = statusItem.button else { return }

        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        btn.image = NSImage(systemSymbolName: "eye.fill", accessibilityDescription: "redeye")?
            .withSymbolConfiguration(config)
        btn.image?.isTemplate = true
        btn.title = ""
        btn.imagePosition = .imageOnly
    }

    // MARK: - Actions

    private func toggleLowBatteryPreview() {
        if lowBatteryPreviewTimer != nil {
            stopLowBatteryPreview()
        } else {
            startLowBatteryPreview()
        }
    }

    private func startLowBatteryPreview() {
        lowBatteryPreviewPercentage = 20
        showLowBatteryPreviewFrame()
        settingsController?.updateLowBatteryPreview(isPreviewing: true, percentage: lowBatteryPreviewPercentage)

        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            lowBatteryPreviewPercentage -= 1
            guard lowBatteryPreviewPercentage >= 0 else {
                stopLowBatteryPreview()
                return
            }

            showLowBatteryPreviewFrame()
        }
        RunLoop.main.add(timer, forMode: .common)
        lowBatteryPreviewTimer = timer
    }

    private func showLowBatteryPreviewFrame() {
        overlayManager.updateLowBatteryPreview(percentage: lowBatteryPreviewPercentage)
        settingsController?.updateLowBatteryPreview(isPreviewing: true, percentage: lowBatteryPreviewPercentage)
    }

    private func stopLowBatteryPreview() {
        lowBatteryPreviewTimer?.invalidate()
        lowBatteryPreviewTimer = nil
        settingsController?.updateLowBatteryPreview(isPreviewing: false)
        overlayManager.endPreview()
    }

    private func openSettings(tab: SettingsTab = .general) {
        if settingsController == nil {
            settingsController = SettingsWindowController(
                overlayManager: overlayManager,
                updaterController: updaterController,
                onShowMenuBarIconChanged: { [weak self] show in
                    self?.applyMenuBarVisibility(show)
                },
                onLowBatteryPreviewToggle: { [weak self] in
                    self?.toggleLowBatteryPreview()
                },
                onCheckForUpdates: { [weak self] in
                    guard let self else { return }
                    updaterController.checkForUpdates(settingsController)
                }
            )
        }
        settingsController?.select(tab)
        settingsController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func openPreferences() {
        openSettings(tab: .general)
    }

    @objc private func openAbout() {
        openSettings(tab: .about)
    }
}
