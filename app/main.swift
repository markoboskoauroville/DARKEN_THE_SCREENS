// Darken the Screens (Mantra). Marko, 30.10.2026: "Now build another startup called Darken the Screens. It's going to
// use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut
// again to lighten the screen to full lightness", then "Repeating the shortcut key Control Option Command F1."
// v2, the same day: "It needs to work the same way as when I press the brightness keys with the sun symbol ... The light
// on the screen should go down, but the screen should not go completely dark", "The screen needs to stay visible over VNC",
// "emulate key pressing on the mac keyboard to darken and lighten the leds on the screen, only that".
//
// ⌃⌥⌘F1 goes between the two. v4 (2.11.2026): both screens together, the built-in and the BenQ, set in the same moment
// through BetterDisplay to their lowest light that still lights, and again to full light. Only the backlight: the picture
// is untouched, so VNC and screencapture see it as before.
import AppKit
import Carbon

let VERSION = 4
let NAME = "Darken the Screens (Mantra)"

enum Ink {
    static let green = NSColor(calibratedRed: 0.30, green: 0.82, blue: 0.45, alpha: 1)
    static let dim = NSColor(calibratedWhite: 0.55, alpha: 1)
    static let red = NSColor(calibratedRed: 0.95, green: 0.33, blue: 0.30, alpha: 1)
    static let amber = NSColor(calibratedRed: 1.0, green: 0.70, blue: 0.20, alpha: 1)
    static let x = NSColor(calibratedRed: 0x7A / 255, green: 0x80 / 255, blue: 0x87 / 255, alpha: 1)
}

// MARK: the darkness, both screens at once, through BetterDisplay
// v4 (Marko, 2.11.2026: "It needs to darken both display at the same time and undarken both display at the same time"):
// the sun keys reached only the screen BetterDisplay gave them to (the one under the mouse). Now every display is set
// directly, all in the same moment: the backlight (built-in) and DDC (BenQ) hardware brightness, never the picture,
// so VNC still sees it. BetterDisplay's own command line sends the order to the running BetterDisplay.

final class Darkness {
    static let shared = Darkness()
    private(set) var dark = false
    var changed: () -> Void = {}
    static let tool = "/Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay"
    static let low = 0.0625                                                     // one keyboard step of sixteen: the lowest
                                                                                // light that still lights (DDC 0 still lights)

    func toggle() { dark ? lighten() : darken() }
    func darken() { dark = true; set(dark: true); changed() }
    func lighten() { dark = false; set(dark: false); changed() }

    // every display BetterDisplay knows, each its own process, all started together
    private func set(dark: Bool) {
        DispatchQueue.global().async {
            let tags = Darkness.displays()
            for (tag, builtIn) in tags {
                let level = dark ? (builtIn ? Darkness.low : 0) : 1
                Darkness.run(["set", "-tagID=\(tag)", "-hardwareBrightness=\(level)"], wait: false)
            }
        }
    }

    // [tagID: built-in?] of the displays connected now
    static func displays() -> [(String, Bool)] {
        guard let out = run(["get", "-identifiers"], wait: true),
              let arr = try? JSONSerialization.jsonObject(with: Data(("[" + out + "]").utf8)) as? [[String: Any]] else { return [] }
        return arr.compactMap { d in
            guard d["deviceType"] as? String == "Display", let tag = d["tagID"] as? String else { return nil }
            return (tag, (d["registryLocation"] as? String ?? "").contains("/disp0@"))
        }
    }

    @discardableResult static func run(_ args: [String], wait: Bool) -> String? {
        let p = Process(); p.executableURL = URL(fileURLWithPath: tool); p.arguments = args
        let pipe = Pipe(); p.standardOutput = pipe; p.standardError = FileHandle.nullDevice
        guard (try? p.run()) != nil else { return nil }
        guard wait else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile(); p.waitUntilExit()
        return String(data: data, encoding: .utf8)
    }

    static var allowed: Bool { FileManager.default.isExecutableFile(atPath: tool) }
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
        perm.toolTip = "BetterDisplay is missing: it sets the brightness of both screens"
        let top = NSStackView(views: [title, word("ON", Ink.green, nil), off, spacer, topWord, perm, x])
        top.spacing = 10

        let key = wrapping(keyOK
            ? "⌃⌥⌘F1 dims both screens together to the lowest light; ⌃⌥⌘F1 again brings both to full light. The picture stays, VNC sees it."
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
        NSWorkspace.shared.open(URL(string: "https://github.com/waydabber/BetterDisplay")!)
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
