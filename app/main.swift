// Darken the Screens (Mantra). Marko, 30.10.2026: "Now build another startup called Darken the Screens. It's going to
// use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut
// again to lighten the screen to full lightness", then "Repeating the shortcut key Control Option Command F1."
// v2, the same day: "It needs to work the same way as when I press the brightness keys with the sun symbol ... The light
// on the screen should go down, but the screen should not go completely dark", "The screen needs to stay visible over VNC",
// "emulate key pressing on the mac keyboard to darken and lighten the leds on the screen, only that".
//
// ⌃⌥⌘F1 goes between the two: dark presses the brightness-down key (the sun) to the bottom and once up again, so the light
// is at its lowest step that still lights; light presses brightness-up to full. Only the keys: the picture is untouched,
// so VNC and screencapture see it as before. Posting the keys needs Accessibility (PERMISSIONS, top right).
import AppKit
import Carbon

let VERSION = 3
let NAME = "Darken the Screens (Mantra)"

enum Ink {
    static let green = NSColor(calibratedRed: 0.30, green: 0.82, blue: 0.45, alpha: 1)
    static let dim = NSColor(calibratedWhite: 0.55, alpha: 1)
    static let red = NSColor(calibratedRed: 0.95, green: 0.33, blue: 0.30, alpha: 1)
    static let amber = NSColor(calibratedRed: 1.0, green: 0.70, blue: 0.20, alpha: 1)
    static let x = NSColor(calibratedRed: 0x7A / 255, green: 0x80 / 255, blue: 0x87 / 255, alpha: 1)
}

// MARK: the darkness, by the brightness keys

final class Darkness {
    static let shared = Darkness()
    private(set) var dark = false
    private var queue: [CGKeyCode] = []
    private var tick: Timer?
    var changed: () -> Void = {}

    static let up: CGKeyCode = 144, down: CGKeyCode = 145                        // the sun keys, as key codes (the NX media
                                                                                // event does nothing on Apple silicon)
    static let steps = 16                                                       // the keyboard's steps from off to full

    func toggle() { dark ? lighten() : darken() }

    // the bottom (16 down), then one up: the lowest step that still lights
    func darken() { dark = true; press(Array(repeating: Darkness.down, count: Darkness.steps) + [Darkness.up]); changed() }
    func lighten() { dark = false; press(Array(repeating: Darkness.up, count: Darkness.steps)); changed() }

    // the presses one after another, 30 ms apart, once ⌃⌥⌘ are let go (⌥ with the sun opens Displays settings)
    private func press(_ keys: [CGKeyCode]) {
        tick?.invalidate()
        queue = keys
        let since = Date()
        tick = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] t in
            guard let self else { t.invalidate(); return }
            let held = NSEvent.modifierFlags.intersection([.control, .option, .command, .shift])
            if !held.isEmpty && Date().timeIntervalSince(since) < 2 { return }
            guard !self.queue.isEmpty else { t.invalidate(); return }
            Darkness.key(self.queue.removeFirst())
        }
    }

    // one press of a brightness key, down and up, with no modifiers (⌃⌥⌘ may still be on the keyboard's state)
    static func key(_ code: CGKeyCode) {
        for down in [true, false] {
            let e = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: down)
            e?.flags = []
            e?.post(tap: .cghidEventTap)
        }
    }

    static var allowed: Bool { CGPreflightPostEventAccess() }
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

// MARK: the window: ON / OFF, TOP and ✕ on the first row, the key, the switch
// v3 (Marko, 31.10.2026: "Each needs to have the same user interface elements. On, off and top"): TOP beside ✕, green =
// this window stays above every other window (UserDefaults "onTop", applied at launch); the QUIT at the bottom right is
// gone (MANTRA_MANIFEST swift-apps.md "No QUIT": OFF is the way out). Every word is an Accessibility button
// (off, top, permissions, close). TOP lifts only this window; the darkness itself is the brightness keys, no window.

final class Window: NSObject {
    let window: NSWindow
    let state = NSTextField(labelWithString: "")
    let button = NSButton(title: "", target: nil, action: nil)
    var onTop = UserDefaults.standard.bool(forKey: "onTop")
    lazy var topWord: NSButton = {
        let b = NSButton(title: "TOP", target: self, action: #selector(toggleTop))
        b.isBordered = false
        b.setAccessibilityIdentifier("top"); b.setAccessibilityLabel("Top")
        b.toolTip = "Always on top: green, this window stays above every other window"
        return b
    }()
    lazy var perm: NSButton = {
        let b = NSButton(title: "PERMISSIONS", target: self, action: #selector(permissions))
        b.isBordered = false
        b.attributedTitle = NSAttributedString(string: "PERMISSIONS", attributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold), .foregroundColor: Ink.amber])
        b.setAccessibilityIdentifier("permissions"); b.setAccessibilityLabel("Permissions")
        return b
    }()

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
        x.setAccessibilityIdentifier("close"); x.setAccessibilityLabel("Close window")
        let off = word("OFF", Ink.dim, #selector(quit))
        off.setAccessibilityIdentifier("off"); off.setAccessibilityLabel("Off")
        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        perm.isHidden = Darkness.allowed
        perm.toolTip = "Posting the brightness keys needs Accessibility: click to open that page of System Settings"
        let top = NSStackView(views: [title, word("ON", Ink.green, nil), off, spacer, topWord, perm, x])
        top.spacing = 10

        let key = wrapping(keyOK
            ? "⌃⌥⌘F1 presses the brightness key down to the lowest light; ⌃⌥⌘F1 again presses it up to full light. The picture stays, VNC sees it."
            : "⌃⌥⌘F1 is taken by another app, so the key does nothing. The button below still works.")
        if !keyOK { key.textColor = Ink.red }
        state.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        button.target = self; button.action = #selector(toggle)
        button.bezelStyle = .rounded
        let col = NSStackView(views: [top, key, NSStackView(views: [button, state]), NSView()])
        col.orientation = .vertical
        col.alignment = .leading
        col.spacing = 14
        col.edgeInsets = NSEdgeInsets(top: 10, left: 18, bottom: 12, right: 8)
        col.translatesAutoresizingMaskIntoConstraints = false
        for v in [top] { v.widthAnchor.constraint(equalTo: col.widthAnchor, constant: -26).isActive = true }
        key.widthAnchor.constraint(equalTo: col.widthAnchor, constant: -36).isActive = true
        let root = NSView()
        root.addSubview(col)
        NSLayoutConstraint.activate([col.leadingAnchor.constraint(equalTo: root.leadingAnchor), col.trailingAnchor.constraint(equalTo: root.trailingAnchor),
                                     col.topAnchor.constraint(equalTo: root.topAnchor), col.bottomAnchor.constraint(equalTo: root.bottomAnchor)])
        window.contentView = root
        floatTop()
        show()
    }

    func floatTop() {
        window.level = onTop ? .floating : .normal
        topWord.attributedTitle = NSAttributedString(string: "TOP", attributes: [.font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold), .foregroundColor: onTop ? Ink.green : Ink.dim])
        topWord.setAccessibilityValue(onTop ? "on" : "off")
    }
    @objc func toggleTop() {
        onTop.toggle()
        UserDefaults.standard.set(onTop, forKey: "onTop")
        floatTop()
    }

    func show() {
        let d = Darkness.shared.dark
        button.title = d ? "Light the screens" : "Darken the screens"
        state.stringValue = d ? "DARK" : "LIGHT"
        state.textColor = d ? Ink.dim : Ink.green
        perm.isHidden = Darkness.allowed
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
    @objc func permissions() {
        CGRequestPostEventAccess()
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
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
        // --shot <png>: the window drawn off screen at its minimum size, then quit (a test: nothing stored, no key pressed)
        if let i = CommandLine.arguments.firstIndex(of: "--shot"), i + 1 < CommandLine.arguments.count {
            let w = win.window, v = w.contentView!
            w.setContentSize(w.minSize); v.layoutSubtreeIfNeeded()
            if let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) {
                v.cacheDisplay(in: v.bounds, to: rep)
                // on the window's own background, so the labels show as on screen
                let img = NSImage(size: v.bounds.size)
                img.lockFocus()
                v.effectiveAppearance.performAsCurrentDrawingAppearance {
                    NSColor.windowBackgroundColor.setFill(); NSRect(origin: .zero, size: v.bounds.size).fill()
                }
                rep.draw(in: NSRect(origin: .zero, size: v.bounds.size), from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
                img.unlockFocus()
                if let t = img.tiffRepresentation, let r = NSBitmapImageRep(data: t) {
                    try? r.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: CommandLine.arguments[i + 1]))
                }
            }
            // and the Accessibility identifiers the window carries (the window itself stays off screen)
            func ids(_ v: NSView) -> [String] { [v.accessibilityIdentifier()].filter { !$0.isEmpty } + v.subviews.flatMap(ids) }
            print("accessibility:", ids(v).joined(separator: " "))
            exit(0)
        }
        Darkness.shared.changed = { [weak self] in self?.win.show() }
        // --login (the star at login): no window; the key works from the first moment
        if !CommandLine.arguments.contains("--login") { win.open() }
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in self?.win.show() }
        // tests and the star: com.mantra.darkenthescreens.toggle does what the key does
        DistributedNotificationCenter.default().addObserver(forName: Notification.Name("com.mantra.darkenthescreens.toggle"), object: nil, queue: .main) { _ in
            Darkness.shared.toggle()
        }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool { win.open(); return false }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = Delegate()
app.delegate = delegate
app.run()
