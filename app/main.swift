// Darken the Screens (Mantra). Marko, 30.10.2026: "Now build another startup called Darken the Screens. It's going to
// use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut
// again to lighten the screen to full lightness", then "Repeating the shortcut key Control Option Command F1."
//
// ⌃⌥⌘F1 goes between the two extremes. Dark: every display's gamma goes to zero (the picture and the cursor), and a
// black window above everything covers any display whose gamma cannot be set. Light: the displays' own colour settings
// come back and the windows go. If the app ends while dark, macOS gives the gamma back by itself.
import AppKit
import Carbon

let VERSION = 1
let NAME = "Darken the Screens (Mantra)"

enum Ink {
    static let green = NSColor(calibratedRed: 0.30, green: 0.82, blue: 0.45, alpha: 1)
    static let dim = NSColor(calibratedWhite: 0.55, alpha: 1)
    static let red = NSColor(calibratedRed: 0.95, green: 0.33, blue: 0.30, alpha: 1)
    static let x = NSColor(calibratedRed: 0x7A / 255, green: 0x80 / 255, blue: 0x87 / 255, alpha: 1)
}

// MARK: the darkness

final class Darkness {
    static let shared = Darkness()
    private(set) var dark = false
    private var curtains: [NSWindow] = []
    private var fade: Timer?
    var changed: () -> Void = {}

    func toggle() { dark ? lighten() : darken() }

    func displays() -> [CGDirectDisplayID] {
        var n: UInt32 = 0
        CGGetOnlineDisplayList(0, nil, &n)
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(n))
        CGGetOnlineDisplayList(n, &ids, &n)
        return Array(ids.prefix(Int(n)))
    }

    // the gamma from what it is now to `to` (0 dark, 1 the display's own), in 0.4 s
    func ramp(to target: Float, done: @escaping () -> Void) {
        fade?.invalidate()
        let ids = displays(), steps = 12
        var i = 0
        fade = Timer.scheduledTimer(withTimeInterval: 0.4 / Double(steps), repeats: true) { t in
            i += 1
            let k = Float(i) / Float(steps), level = target == 0 ? 1 - k : k
            for d in ids { CGSetDisplayTransferByFormula(d, 0, level, 1, 0, level, 1, 0, level, 1) }
            if i >= steps { t.invalidate(); done() }
        }
    }

    func darken() {
        guard !dark else { return }
        dark = true
        // the curtains first, transparent, then black: a display that ignores gamma (AirPlay, Sidecar) still goes dark
        curtains = NSScreen.screens.map { s in
            let w = NSWindow(contentRect: s.frame, styleMask: .borderless, backing: .buffered, defer: false)
            w.level = .screenSaver
            w.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
            w.backgroundColor = .black
            w.alphaValue = 0
            w.ignoresMouseEvents = true
            w.isReleasedWhenClosed = false
            w.setFrame(s.frame, display: false)
            w.orderFrontRegardless()
            return w
        }
        NSAnimationContext.runAnimationGroup { c in c.duration = 0.4; for w in curtains { w.animator().alphaValue = 1 } }
        ramp(to: 0) {}
        NSCursor.setHiddenUntilMouseMoves(true)
        changed()
    }

    func lighten() {
        guard dark else { return }
        dark = false
        let going = curtains
        curtains = []
        ramp(to: 1) { CGDisplayRestoreColorSyncSettings() }
        NSAnimationContext.runAnimationGroup({ c in c.duration = 0.4; for w in going { w.animator().alphaValue = 0 } },
                                             completionHandler: { for w in going { w.orderOut(nil) } })
        changed()
    }
}

// MARK: ⌃⌥⌘F1, a Carbon hot key (no permission needed, the key does not reach the front app)

final class HotKey {
    static var handler: () -> Void = {}
    private var ref: EventHotKeyRef?
    init?(code: UInt32, mods: UInt32) {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in DispatchQueue.main.async { HotKey.handler() }; return noErr },
                            1, &spec, nil, nil)
        let id = EventHotKeyID(signature: OSType(0x44524B4E), id: 1)            // 'DRKN'
        guard RegisterEventHotKey(code, mods, id, GetApplicationEventTarget(), 0, &ref) == noErr else { return nil }
    }
}

// MARK: the window: ON / OFF and ✕ on the first row, the key, the switch, QUIT at the bottom right

final class Window: NSObject {
    let window: NSWindow
    let state = NSTextField(labelWithString: "")
    let button = NSButton(title: "", target: nil, action: nil)

    init(keyOK: Bool) {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 220), styleMask: [.titled, .closable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "\(NAME) v\(VERSION)"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 360, height: 200)
        super.init()

        func word(_ s: String, _ c: NSColor, _ sel: Selector?, size: CGFloat = 13) -> NSButton {
            let b = NSButton(title: s, target: self, action: sel)
            b.isBordered = false
            b.attributedTitle = NSAttributedString(string: s, attributes: [.font: NSFont.monospacedSystemFont(ofSize: size, weight: .bold), .foregroundColor: c])
            return b
        }
        func wrapping(_ s: String) -> NSTextField {
            let l = NSTextField(wrappingLabelWithString: s)
            l.font = .systemFont(ofSize: 13)
            l.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return l
        }
        let title = NSTextField(labelWithString: "DARKEN THE SCREENS")
        title.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        let x = NSButton(title: "", target: self, action: #selector(close))
        x.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "close")?.withSymbolConfiguration(.init(pointSize: 14, weight: .semibold))
        x.imagePosition = .imageOnly; x.isBordered = false; x.contentTintColor = Ink.x
        x.toolTip = "Close this window; Darken the Screens stays on and ⌃⌥⌘F1 still works"
        x.widthAnchor.constraint(equalToConstant: 28).isActive = true
        x.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let top = NSStackView(views: [title, word("ON", Ink.green, nil), word("OFF", Ink.dim, #selector(quit)), spacer, x])
        top.spacing = 10

        let key = wrapping(keyOK
            ? "⌃⌥⌘F1 darkens every screen to complete darkness; ⌃⌥⌘F1 again brings them back to full light."
            : "⌃⌥⌘F1 is taken by another app, so the key does nothing. The button below still works.")
        if !keyOK { key.textColor = Ink.red }
        state.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        button.target = self; button.action = #selector(toggle)
        button.bezelStyle = .rounded
        let quitRow = NSStackView(views: [NSView(), word("QUIT", Ink.red, #selector(quit), size: 12)])
        let col = NSStackView(views: [top, key, NSStackView(views: [button, state]), NSView(), quitRow])
        col.orientation = .vertical
        col.alignment = .leading
        col.spacing = 14
        col.edgeInsets = NSEdgeInsets(top: 10, left: 18, bottom: 12, right: 8)
        col.translatesAutoresizingMaskIntoConstraints = false
        for v in [top, quitRow] { v.widthAnchor.constraint(equalTo: col.widthAnchor, constant: -26).isActive = true }
        key.widthAnchor.constraint(equalTo: col.widthAnchor, constant: -36).isActive = true
        let root = NSView()
        root.addSubview(col)
        NSLayoutConstraint.activate([col.leadingAnchor.constraint(equalTo: root.leadingAnchor), col.trailingAnchor.constraint(equalTo: root.trailingAnchor),
                                     col.topAnchor.constraint(equalTo: root.topAnchor), col.bottomAnchor.constraint(equalTo: root.bottomAnchor)])
        window.contentView = root
        show()
    }

    func show() {
        let d = Darkness.shared.dark
        button.title = d ? "Light the screens" : "Darken the screens"
        state.stringValue = d ? "DARK" : "LIGHT"
        state.textColor = d ? Ink.dim : Ink.green
    }

    func open() {
        show()
        if !window.isVisible { window.center() }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    @objc func toggle() {
        // from the window: give it a moment so the click is let go before the dark comes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { Darkness.shared.toggle() }
    }
    @objc func close() { window.orderOut(nil) }
    @objc func quit() { NSApp.terminate(nil) }
}

final class Delegate: NSObject, NSApplicationDelegate {
    var win: Window!
    var hotkey: HotKey?
    func applicationDidFinishLaunching(_ n: Notification) {
        HotKey.handler = { Darkness.shared.toggle() }
        hotkey = HotKey(code: UInt32(kVK_F1), mods: UInt32(controlKey | optionKey | cmdKey))
        win = Window(keyOK: hotkey != nil)
        Darkness.shared.changed = { [weak self] in self?.win.show() }
        // --login (the star at login): no window; the key works from the first moment
        if !CommandLine.arguments.contains("--login") { win.open() }
        // a display plugged in or out while dark: the curtains follow
        NotificationCenter.default.addObserver(forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { _ in
            if Darkness.shared.dark { Darkness.shared.lighten(); Darkness.shared.darken() }
        }
        // tests and the star: com.mantra.darkenthescreens.toggle does what the key does
        DistributedNotificationCenter.default().addObserver(forName: Notification.Name("com.mantra.darkenthescreens.toggle"), object: nil, queue: .main) { _ in
            Darkness.shared.toggle()
        }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool { win.open(); return false }
    func applicationWillTerminate(_ n: Notification) { CGDisplayRestoreColorSyncSettings() }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = Delegate()
app.delegate = delegate
app.run()
