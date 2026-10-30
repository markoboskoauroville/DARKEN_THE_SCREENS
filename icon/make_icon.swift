// The icon: a screen, its left half black, its right half white (dark and light, the two extremes).
import AppKit
let dir = CommandLine.arguments[1]
try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
for (px, name) in [(16, "16x16"), (32, "16x16@2x"), (32, "32x32"), (64, "32x32@2x"), (128, "128x128"), (256, "128x128@2x"),
                   (256, "256x256"), (512, "256x256@2x"), (512, "512x512"), (1024, "512x512@2x")] {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let r = NSRect(x: s * 0.08, y: s * 0.08, width: s * 0.84, height: s * 0.84)
    let p = NSBezierPath(roundedRect: r, xRadius: s * 0.2, yRadius: s * 0.2)
    NSColor(white: 0.18, alpha: 1).setFill(); p.fill()
    let screen = NSRect(x: s * 0.2, y: s * 0.3, width: s * 0.6, height: s * 0.42)
    NSColor.white.setFill(); NSBezierPath(roundedRect: screen, xRadius: s * 0.03, yRadius: s * 0.03).fill()
    NSColor.black.setFill(); NSRect(x: screen.minX + s * 0.02, y: screen.minY + s * 0.02, width: screen.width / 2 - s * 0.02, height: screen.height - s * 0.04).fill()
    NSColor.white.setFill(); NSRect(x: s * 0.44, y: s * 0.2, width: s * 0.12, height: s * 0.1).fill()
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(dir)/icon_\(name).png"))
}
