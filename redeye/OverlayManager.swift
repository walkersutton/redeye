import Cocoa

class OverlayManager: NSObject {
    private var windows: [OverlayWindow] = []
    private var currentAlpha: CGFloat = 0
    private var lastState: BatteryState?
    private var isPreviewing = false

    override init() {
        super.init()
        rebuild()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
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

    func update(_ state: BatteryState) {
        lastState = state
        guard !isPreviewing else { return }
        applyState(state)
    }

    func updateLowBatteryPreview(percentage: Int, startPercentage: Int = 20) {
        isPreviewing = true

        let start = max(startPercentage, 1)
        let pct = min(max(percentage, 0), start)
        let maxAlpha = CGFloat(Preferences.maxIntensity) / 100.0
        let alpha = CGFloat(start - pct) / CGFloat(start) * maxAlpha

        currentAlpha = alpha
        setAlpha(alpha, animated: false)
    }

    func endPreview() {
        isPreviewing = false
        if let state = lastState { applyState(state) }
    }

    private func applyState(_ state: BatteryState) {
        let threshold = Preferences.threshold
        let maxAlpha = CGFloat(Preferences.maxIntensity) / 100.0

        let target: CGFloat
        if let pct = state.percentage, pct <= threshold, !state.isCharging {
            let t = max(threshold, 1)
            target = CGFloat(t - pct) / CGFloat(t) * maxAlpha
        } else {
            target = 0
        }

        guard abs(target - currentAlpha) > 0.005 else { return }
        currentAlpha = target
        setAlpha(target, animated: true)
    }

    private func setAlpha(_ alpha: CGFloat, animated: Bool) {
        if alpha > 0 {
            windows.forEach { $0.orderFrontRegardless() }
        }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = animated ? 2.0 : 0
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.windows.forEach { $0.animator().alphaValue = alpha }
        }, completionHandler: {
            if alpha == 0 { self.windows.forEach { $0.orderOut(nil) } }
        })
    }
}
