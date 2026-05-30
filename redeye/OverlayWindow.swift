import Cocoa

class OverlayWindow: NSWindow {
    init(screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        backgroundColor = NSColor(deviceRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        isOpaque = false
        alphaValue = 0
        hasShadow = false
        ignoresMouseEvents = true
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
    }
}
