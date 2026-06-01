import Cocoa
import SwiftUI
import Sparkle

// MARK: - Constants

enum Preferences {
    static let threshold = 10
    static let maxIntensity = 69
    static let showMenuBarIconKey = "showMenuBarIcon"
}

// MARK: - Tab

enum SettingsTab: String, Hashable {
    case general, about
}

// MARK: - Observable state

class SettingsState: ObservableObject {
    @Published var selectedTab: SettingsTab = .general
    @Published var isLowBatteryPreviewing = false
    @Published var lowBatteryPreviewPercentage = 20
}

// MARK: - Window controller

class SettingsWindowController: NSWindowController {
    private let state = SettingsState()

    init(
        overlayManager: OverlayManager,
        updaterController: SPUStandardUpdaterController,
        onShowMenuBarIconChanged: @escaping (Bool) -> Void,
        onLowBatteryPreviewToggle: @escaping () -> Void,
        onCheckForUpdates: @escaping () -> Void
    ) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 550),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "redeye"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        super.init(window: window)

        window.contentView = NSHostingView(rootView: SettingsRootView(
            state: state,
            updaterController: updaterController,
            onShowMenuBarIconChanged: onShowMenuBarIconChanged,
            onLowBatteryPreviewToggle: onLowBatteryPreviewToggle,
            onCheckForUpdates: onCheckForUpdates
        ))
        window.center()
    }

    required init?(coder: NSCoder) { fatalError() }

    func select(_ tab: SettingsTab) {
        state.selectedTab = tab
    }

    func updateLowBatteryPreview(isPreviewing: Bool, percentage: Int = 20) {
        state.isLowBatteryPreviewing = isPreviewing
        state.lowBatteryPreviewPercentage = percentage
    }
}

// MARK: - Design tokens

private extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >>  8) & 0xff) / 255,
            blue:  Double( hex        & 0xff) / 255
        )
    }
}

private struct RDToken {
    let dark: Bool

    var sidebarBg:     Color { dark ? Color(hex: 0x232326) : Color(hex: 0xe7e7ea) }
    var contentBg:     Color { dark ? Color(hex: 0x1c1c1e) : Color(hex: 0xf4f4f6) }
    var cardBg:        Color { dark ? Color(hex: 0x2b2b2e) : .white }
    var divider:       Color { dark ? .white.opacity(0.085) : .black.opacity(0.085) }
    var text:          Color { dark ? .white : Color(hex: 0x1b1b1f) }
    var text2:         Color { dark ? Color(red: 0.922, green: 0.922, blue: 0.961).opacity(0.62)
                                    : Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.62) }
    var text3:         Color { dark ? Color(red: 0.922, green: 0.922, blue: 0.961).opacity(0.34)
                                    : Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.40) }
    var selBg:         Color { dark ? .white.opacity(0.10) : .black.opacity(0.075) }
    var controlBg:     Color { dark ? Color(hex: 0x3a3a3d) : .white }
    var controlBorder: Color { dark ? .white.opacity(0.10) : .black.opacity(0.14) }
    var accent:        Color { dark ? Color(hex: 0xff453a) : Color(hex: 0xff3b30) }
    var topEdge:       Color { dark ? .white.opacity(0.06) : .white.opacity(0.70) }
    var pillBg:        Color { dark ? .white.opacity(0.07) : .black.opacity(0.04) }
    var pillBorder:    Color { dark ? .white.opacity(0.10) : .black.opacity(0.08) }
}

// MARK: - Root layout

private struct SettingsRootView: View {
    @ObservedObject var state: SettingsState
    @Environment(\.colorScheme) var colorScheme
    let updaterController: SPUStandardUpdaterController
    let onShowMenuBarIconChanged: (Bool) -> Void
    let onLowBatteryPreviewToggle: () -> Void
    let onCheckForUpdates: () -> Void

    var body: some View {
        let t = RDToken(dark: colorScheme == .dark)
        HStack(spacing: 0) {
            SidebarView(selected: $state.selectedTab, t: t)
                .frame(width: 196)
            ContentArea(
                state: state,
                updaterController: updaterController,
                onShowMenuBarIconChanged: onShowMenuBarIconChanged,
                onLowBatteryPreviewToggle: onLowBatteryPreviewToggle,
                onCheckForUpdates: onCheckForUpdates,
                t: t
            )
        }
        .ignoresSafeArea()
        .tint(t.accent)
    }
}

// MARK: - Sidebar

private struct SidebarView: View {
    @Binding var selected: SettingsTab
    let t: RDToken

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            SidebarNavRow(label: "General", icon: "gearshape",   isSelected: selected == .general, t: t) { selected = .general }
            SidebarNavRow(label: "About",   icon: "info.circle", isSelected: selected == .about,   t: t) { selected = .about   }
            Spacer()
        }
        .padding(.top, 44)
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .frame(maxHeight: .infinity)
        .background(t.sidebarBg)
    }
}

private struct SidebarNavRow: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let t: RDToken
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .regular))
                    .frame(width: 17, height: 17)
                    .foregroundStyle(isSelected ? t.text : t.text2)
                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(t.text)
                Spacer()
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(isSelected ? t.selBg : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

// MARK: - Content area

private struct ContentArea: View {
    @ObservedObject var state: SettingsState
    let updaterController: SPUStandardUpdaterController
    let onShowMenuBarIconChanged: (Bool) -> Void
    let onLowBatteryPreviewToggle: () -> Void
    let onCheckForUpdates: () -> Void
    let t: RDToken

    var body: some View {
        ZStack(alignment: .topTrailing) {
            switch state.selectedTab {
            case .general:
                GeneralTab(
                    state: state,
                    updaterController: updaterController,
                    onShowMenuBarIconChanged: onShowMenuBarIconChanged,
                    onLowBatteryPreviewToggle: onLowBatteryPreviewToggle,
                    onCheckForUpdates: onCheckForUpdates,
                    t: t
                )
            case .about:
                AboutTab(t: t)
            }

            if state.selectedTab != .about {
                AppPill(t: t)
                    .padding(.top, 14)
                    .padding(.trailing, 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top)    { t.topEdge.frame(height: 1) }
        .overlay(alignment: .leading) { t.divider.frame(width: 1) }
        .background(t.contentBg)
    }
}

// MARK: - App pill

private struct AppPill: View {
    let t: RDToken

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(LinearGradient(
                        colors: [Color(red: 1, green: 0.357, blue: 0.318),
                                 Color(red: 0.886, green: 0.176, blue: 0.133)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 22, height: 22)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .inset(by: 0.5)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.30), radius: 2, x: 0, y: 1)
                Image(systemName: "eye")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white)
            }
            Text("redeye")
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(t.text)
        }
        .padding(.leading, 7)
        .padding(.trailing, 13)
        .padding(.vertical, 6)
        .background(t.pillBg)
        .clipShape(Capsule())
        .overlay { Capsule().stroke(t.pillBorder, lineWidth: 1) }
    }
}

// MARK: - General tab

private struct GeneralTab: View {
    @ObservedObject var state: SettingsState
    @AppStorage(Preferences.showMenuBarIconKey) private var showMenuBarIcon = true
    @State private var launchAtLogin = LoginItemManager.isEnabled
    @State private var autoUpdates: Bool
    let updaterController: SPUStandardUpdaterController
    let onShowMenuBarIconChanged: (Bool) -> Void
    let onLowBatteryPreviewToggle: () -> Void
    let onCheckForUpdates: () -> Void
    let t: RDToken

    init(state: SettingsState,
         updaterController: SPUStandardUpdaterController,
         onShowMenuBarIconChanged: @escaping (Bool) -> Void,
         onLowBatteryPreviewToggle: @escaping () -> Void,
         onCheckForUpdates: @escaping () -> Void,
         t: RDToken) {
        self.state = state
        self.updaterController = updaterController
        self.onShowMenuBarIconChanged = onShowMenuBarIconChanged
        self.onLowBatteryPreviewToggle = onLowBatteryPreviewToggle
        self.onCheckForUpdates = onCheckForUpdates
        self.t = t
        _autoUpdates = State(initialValue: updaterController.updater.automaticallyChecksForUpdates)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                RDSectionLabel("General", t: t)
                RDCard(t: t) {
                    RDRow("Launch at login", t: t) {
                        Toggle("", isOn: $launchAtLogin)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .onChange(of: launchAtLogin) { val in LoginItemManager.setEnabled(val) }
                    }
                    RDDivider(t: t)
                    RDRow("Show menu bar icon",
                          description: "When hidden, open redeye from the Dock instead.",
                          t: t) {
                        Toggle("", isOn: $showMenuBarIcon)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .onChange(of: showMenuBarIcon) { val in onShowMenuBarIconChanged(val) }
                    }
                }

                RDSectionLabel("Preview", spaced: true, t: t)
                RDCard(t: t) {
                    RDRow("Low battery",
                          description: "See the red screen tint before your battery actually runs low.",
                          t: t) {
                        HStack(spacing: 10) {
                            if state.isLowBatteryPreviewing {
                                Text("\(state.lowBatteryPreviewPercentage)%")
                                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                                    .foregroundStyle(t.text2)
                            }
                            Button(state.isLowBatteryPreviewing ? "Stop preview" : "Preview low battery") {
                                onLowBatteryPreviewToggle()
                            }
                            .buttonStyle(RDButtonStyle(t: t))
                        }
                    }
                }

                RDSectionLabel("Updates", spaced: true, t: t)
                RDCard(t: t) {
                    RDRow("Automatically check for updates", t: t) {
                        Toggle("", isOn: $autoUpdates)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .onChange(of: autoUpdates) { val in
                                updaterController.updater.automaticallyChecksForUpdates = val
                            }
                    }
                    RDDivider(t: t)
                    RDRow("Check for Updates", t: t) {
                        Button("Check now") { onCheckForUpdates() }
                            .buttonStyle(RDButtonStyle(t: t))
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 56)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - About tab

private struct AboutTab: View {
    let t: RDToken

    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 21)
                    .fill(LinearGradient(
                        colors: [Color(red: 1, green: 0.357, blue: 0.318),
                                 Color(red: 0.847, green: 0.157, blue: 0.114)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 86, height: 86)
                    .overlay {
                        RoundedRectangle(cornerRadius: 21)
                            .inset(by: 0.75)
                            .stroke(Color.white.opacity(0.32), lineWidth: 1.5)
                    }
                    .shadow(color: Color(red: 0.851, green: 0.157, blue: 0.114).opacity(0.55), radius: 16, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.28), radius: 6, x: 0, y: 2)
                Image(systemName: "eye")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(.white)
            }

            Text("redeye")
                .font(.system(size: 24, weight: .semibold))
                .tracking(-0.36)
                .foregroundStyle(t.text)
                .padding(.top, 18)

            Text("Version \(version)")
                .font(.system(size: 13))
                .foregroundStyle(t.text2)
                .padding(.top, 5)

            Text("Tints your screen red as your battery runs low — so you never forget to charge.")
                .font(.system(size: 13))
                .foregroundStyle(t.text2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 290)
                .padding(.top, 16)

            HStack(spacing: 9) {
                Link("GitHub", destination: URL(string: "https://github.com/walkersutton/redeye")!)
                    .foregroundStyle(t.accent)
                Text("·").foregroundStyle(t.text3)
                Button("Acknowledgements") {}
                    .buttonStyle(.plain)
                    .foregroundStyle(t.accent)
            }
            .font(.system(size: 13))
            .padding(.top, 20)

            Text("© 2024 Walker Sutton")
                .font(.system(size: 12))
                .foregroundStyle(t.text3)
                .padding(.top, 26)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 56)
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}

// MARK: - Shared components

private struct RDSectionLabel: View {
    let title: String
    var spaced: Bool = false
    let t: RDToken
    init(_ title: String, spaced: Bool = false, t: RDToken) {
        self.title = title; self.spaced = spaced; self.t = t
    }
    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .tracking(-0.15)
            .foregroundStyle(t.text)
            .padding(.top, spaced ? 22 : 0)
            .padding(.bottom, 9)
            .padding(.horizontal, 4)
    }
}

private struct RDCard<Content: View>: View {
    let t: RDToken
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(t.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            if !t.dark {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black.opacity(0.05), lineWidth: 0.5)
            }
        }
        .shadow(color: !t.dark ? .black.opacity(0.04) : .clear, radius: 2, x: 0, y: 1)
    }
}

private struct RDRow<Control: View>: View {
    let label: String
    var description: String? = nil
    let t: RDToken
    @ViewBuilder let control: () -> Control
    init(_ label: String, description: String? = nil, t: RDToken,
         @ViewBuilder control: @escaping () -> Control) {
        self.label = label; self.description = description; self.t = t; self.control = control
    }
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14))
                    .foregroundStyle(t.text)
                if let desc = description {
                    Text(desc)
                        .font(.system(size: 12))
                        .foregroundStyle(t.text2)
                }
            }
            Spacer()
            control()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .frame(minHeight: 46)
    }
}

private struct RDDivider: View {
    let t: RDToken
    var body: some View {
        Rectangle()
            .fill(t.divider)
            .frame(height: 1)
            .padding(.leading, 14)
    }
}

private struct RDButtonStyle: ButtonStyle {
    let t: RDToken
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(t.text)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(t.controlBg)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(t.controlBorder, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.06), radius: 1, x: 0, y: 1)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
    }
}
