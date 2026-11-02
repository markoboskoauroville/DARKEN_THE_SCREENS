# Darken the Screens: requests, word for word

## 30.10.2026: the first request
> "Now build another startup called Darken the Screens. It's going to use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut again to lighten the screen to full lightness. Going between these two extremes with Control + Option + Shift + F1."

**Status:** saved; not built yet (Marko Transcribe v12 being finished first in the same session). Open: what ⌃⌥⇧F1 does between the two extremes.

**30.10.2026, then:** "Repeating the shortcut key Control Option Command F1." / "It is Control Option Command and F1." So one key, ⌃⌥⌘F1, goes between the two extremes: dark, press again, full light (the "Control + Option + Shift" was a slip).

## 30.10.2026: the brightness keys, not the darkness
> "Please fix the Swift app that darkens the screen. It uses the wrong model of darkening. It needs to work the same way as when I press the brightness keys with the sun symbol on my MacBook Pro keyboard. The light on the screen should go down, but the screen should not go completely dark. Only the monitor needs to be dimmed. The screen needs to stay visible over VNC or any other connection to the computer. This is not what was happening. I don't want you to emulate key presses of those buttons."

Then, the correction: *"The transcription is wrong. I want you to emulate key presses to these buttons."*

**So v2:** ⌃⌥⌘F1 presses the brightness-down key (the sun) down to the lowest step that still lights, the same key again presses brightness-up to full light. No black windows, no gamma: the picture is untouched, so VNC sees it.

## 31.10.2026: ON, OFF and TOP in every application

> Please go to all the interface of my applications. Each needs to have the same user interface elements. On, off and top. Please build it in every application.

The first row as MANTRA_MANIFEST swift-apps.md "The first row of every app: ON OFF … TOP ✕": ON, OFF at the left, TOP
(green: the window above every other, UserDefaults `onTop`, applied at launch) beside ✕ at the right; each an
Accessibility button (`off`, `top`, `close`).
**Status:** done 31.10.2026 in v3 (AppKit): TOP beside ✕ on the control window (green = `.floating`, `onTop`, applied at
launch; the darkness is the brightness keys, no overlay, so nothing else is lifted); OFF, TOP, PERMISSIONS, ✕ carry
Accessibility identifiers; the QUIT at the bottom right removed ("No QUIT"). `--shot <png>` draws the window off screen at
its minimum size (360 pt) and lists the identifiers: checked, nothing cut. The running copy quit by its Apple Event quit
and reopened with `--login` (no window at login, as before).

## 2.11.2026: both screens together
> "please fix my darkening display star menu. It needs to darken both display at the same time and undarken both display at the same time"

**Status:** done 2.11.2026 in v4: both displays set directly through BetterDisplay in the same moment (measured dark 0.063 built-in / 0.0 BenQ, light 1.0 / 1.0), no key presses.
