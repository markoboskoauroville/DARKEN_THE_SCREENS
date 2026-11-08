// The Logitech G815's own lights follow the screens (v8, Marko, 8.11.2026): "darken all the lights on my keyboard, leaving
// Control Command out and F1 on the lowest brightness, just so I can press it. Then, when I'm lighting the screen up, the
// keyboard comes back to the previous brightness."
//
// The G815 speaks Logitech HID++ 2.0 on its vendor interface (usage page 0xFF43, usage 0x0602, long reports id 0x11,
// device index 0xFF over USB). Measured on Marko's keyboard 8.11.2026: feature 0x8081 (per-key lighting) at index 0x10,
// 0x8100 (onboard profiles) at 0x11, the same as the open-source g810-led uses.
//   dark:  0x8100 fn1 = 0x02 (host mode), 0x8081 fn6 (one colour for up to 13 keys, 0xFF ends the list), fn7 commits
//   light: 0x8100 fn1 = 0x01 (onboard mode): the keyboard's own stored lighting comes back exactly as it was
// Key ids: HID usage − 3 (F1 0x3A → 0x37); modifiers usage − 0x78 (left Ctrl 0x68, Alt 0x6A, ⌘ = the Windows key 0x6B,
// right 0x6C / 0x6E / 0x6F). The device is opened shared (kIOHIDOptionsTypeNone), so typing is never taken.
import Foundation
import IOKit.hid

final class G815 {
    static let shared = G815()
    private let index8081: UInt8 = 0x10, index8100: UInt8 = 0x11
    /// F1, Ctrl, Option, ⌘ on both sides: the keys of ⌃⌥⌘F1, left at the lowest light
    static let lit: [UInt8] = [0x37, 0x68, 0x6A, 0x6B, 0x6C, 0x6E, 0x6F]
    static let low: (UInt8, UInt8, UInt8) = (0x0C, 0x0C, 0x0C)
    private let queue = DispatchQueue(label: "g815")

    func set(dark: Bool) { queue.async { self.apply(dark: dark) } }

    private func device() -> IOHIDDevice? {
        let m = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        IOHIDManagerSetDeviceMatching(m, [kIOHIDVendorIDKey: 0x046D, kIOHIDPrimaryUsagePageKey: 0xFF43,
                                          kIOHIDPrimaryUsageKey: 0x0602] as CFDictionary)
        guard let set = IOHIDManagerCopyDevices(m) as? Set<IOHIDDevice> else { return nil }
        return set.first { (IOHIDDeviceGetProperty($0, kIOHIDProductKey as CFString) as? String ?? "").contains("G815") }
    }

    private func apply(dark: Bool) {
        guard let d = device() else { NSLog("G815: not connected"); return }
        guard IOHIDDeviceOpen(d, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else { NSLog("G815: open failed"); return }
        defer { IOHIDDeviceClose(d, IOOptionBits(kIOHIDOptionsTypeNone)) }
        func send(_ index: UInt8, _ fn: UInt8, _ args: [UInt8]) {
            var m: [UInt8] = [0x11, 0xFF, index, (fn << 4) | 0x0A] + args
            m += Array(repeating: 0, count: max(0, 20 - m.count))
            _ = IOHIDDeviceSetReport(d, kIOHIDReportTypeOutput, 0x11, m, 20)
            usleep(3000)
        }
        func colour(_ c: (UInt8, UInt8, UInt8), _ keys: [UInt8]) {
            stride(from: 0, to: keys.count, by: 13).forEach { i in
                let chunk = Array(keys[i..<min(i + 13, keys.count)])
                send(index8081, 6, [c.0, c.1, c.2] + chunk + (chunk.count < 13 ? [0xFF] : []))
            }
        }
        if dark {
            send(index8100, 1, [0x02])
            colour((0, 0, 0), (0x01...0xEF).filter { !G815.lit.contains($0) })   // every zone the keyboard has, ids it lacks ignored
            colour(G815.low, G815.lit)
            send(index8081, 7, [])
        } else {
            send(index8100, 1, [0x01])
        }
    }
}
