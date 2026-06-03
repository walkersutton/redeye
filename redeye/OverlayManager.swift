import Cocoa

class OverlayManager: NSObject {
    private var windows: [OverlayWindow] = []
    private var currentAlpha: CGFloat = 0
    private var lastState: BatteryState?
    private var isPreviewing = false
    private var previewPercentage = Double(Preferences.threshold)

    override init() {
        super.init()
        rebuild()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func rebuild() {
        windows.forEach { $0.close() }
        windows = NSScreen.screens.map { OverlayWindow(screen: $0) }
    }

    @objc private func screensChanged() {
        rebuild()
        setAlpha(currentAlpha, animated: false)
    }

    @objc private func preferencesChanged() {
        if isPreviewing {
            updateLowBatteryPreview(percentage: previewPercentage)
        } else if let state = lastState {
            applyState(state)
        }
    }

    func update(_ state: BatteryState) {
        lastState = state
        guard !isPreviewing else { return }
        applyState(state)
    }

    func updateLowBatteryPreview(percentage: Double, startPercentage: Int = Preferences.threshold) {
        isPreviewing = true
        previewPercentage = percentage

        let start = Double(max(startPercentage, 1))
        let pct = min(max(percentage, 0), start)
        let maxAlpha = CGFloat(Preferences.peakOpacity)
        let alpha = alphaForLowBattery(percentage: pct, threshold: start, maxAlpha: maxAlpha)

        currentAlpha = alpha
        setAlpha(alpha, animated: false)
    }

    func endPreview() {
        isPreviewing = false
        if let state = lastState { applyState(state) }
    }

    private func applyState(_ state: BatteryState) {
        let threshold = Preferences.threshold
        let maxAlpha = CGFloat(Preferences.peakOpacity)

        let target: CGFloat = if let pct = state.percentage, pct <= threshold, !state.isCharging {
            alphaForLowBattery(percentage: Double(pct), threshold: Double(threshold), maxAlpha: maxAlpha)
        } else {
            0
        }

        guard abs(target - currentAlpha) > 0.005 else { return }
        currentAlpha = target
        setAlpha(target, animated: true)
    }

    private func alphaForLowBattery(percentage: Double, threshold: Double, maxAlpha: CGFloat) -> CGFloat {
        let t = CGFloat(max(threshold, 1))
        let progress = min(max((t - CGFloat(percentage)) / t, 0), 1)
        let eased = progress * progress * (3 - 2 * progress)
        return eased * maxAlpha
    }

    private func setAlpha(_ alpha: CGFloat, animated: Bool) {
        if alpha > 0 {
            windows.forEach { $0.orderFrontRegardless() }
        }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = animated ? 2.0 : 0
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.windows.forEach { $0.animator().alphaValue = alpha }
        } completionHandler: {
            if alpha == 0 { self.windows.forEach { $0.orderOut(nil) } }
        }
    }
}
