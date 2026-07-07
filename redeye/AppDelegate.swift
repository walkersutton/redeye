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
    private var lowBatteryPreviewPercentage = Double(Preferences.defaultThreshold)
    private let lowBatteryPreviewFrameInterval = 1.0 / 30.0
    private let lowBatteryPreviewDuration = 4.0

    func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
        openSettings()
        return true
    }

    func applicationDidFinishLaunching(_: Notification) {
        NSApp.mainMenu = nil
        configureInstallDefaults()

        if UserDefaults.standard.bool(forKey: Preferences.launchAtLoginKey) {
            LoginItemManager.setEnabled(true)
        }

        let showIcon = UserDefaults.standard.bool(forKey: Preferences.showMenuBarIconKey)
        NSApp.setActivationPolicy(.accessory)
        buildStatusItem()
        statusItem.isVisible = showIcon

        batteryMonitor.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.apply($0) }
            .store(in: &cancellables)

        batteryMonitor.start()
    }

    // MARK: - Setup

    private func configureInstallDefaults() {
        let defaults = UserDefaults.standard
        let hadPersistentDefaults = Bundle.main.bundleIdentifier
            .flatMap { defaults.persistentDomain(forName: $0) }?
            .isEmpty == false

        defaults.register(defaults: [
            Preferences.thresholdKey: Preferences.defaultThreshold,
            Preferences.peakOpacityKey: Preferences.defaultPeakOpacity,
            Preferences.showMenuBarIconKey: true,
            Preferences.launchAtLoginKey: true
        ])

        guard defaults.object(forKey: Preferences.didApplyInstallDefaultsKey) == nil else { return }

        if !hadPersistentDefaults {
            defaults.set(true, forKey: Preferences.showMenuBarIconKey)
            updaterController.updater.automaticallyChecksForUpdates = true
        }

        defaults.set(true, forKey: Preferences.didApplyInstallDefaultsKey)
    }

    private func buildStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        configureStatusButton()

        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openPreferences), keyEquivalent: "")
        settingsItem.target = self

        let aboutItem = NSMenuItem(title: "About redeye", action: #selector(openAbout), keyEquivalent: "")
        aboutItem.target = self

        let menu = NSMenu()
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(aboutItem)
        let quitItem = NSMenuItem(title: "Quit redeye", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Preferences

    func applyMenuBarVisibility(_ show: Bool) {
        statusItem?.isVisible = show
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            self.settingsController?.window?.makeKeyAndOrderFront(nil)
        }
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
        lowBatteryPreviewPercentage = Double(Preferences.threshold)
        showLowBatteryPreviewFrame()
        settingsController?.updateLowBatteryPreview(isPreviewing: true, percentage: displayedLowBatteryPreviewPercentage)

        let decrement = Double(max(Preferences.threshold, 1)) * lowBatteryPreviewFrameInterval / lowBatteryPreviewDuration
        let timer = Timer(timeInterval: lowBatteryPreviewFrameInterval, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            lowBatteryPreviewPercentage -= decrement
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
        settingsController?.updateLowBatteryPreview(isPreviewing: true, percentage: displayedLowBatteryPreviewPercentage)
    }

    private var displayedLowBatteryPreviewPercentage: Int {
        Int(ceil(max(lowBatteryPreviewPercentage, 0)))
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

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc private func openPreferences() {
        openSettings(tab: .general)
    }

    @objc private func openAbout() {
        openSettings(tab: .about)
    }
}
