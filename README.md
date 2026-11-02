# Darken the Screens (Mantra)

**v4 · github.com/markoboskoauroville/DARKEN_THE_SCREENS (private) · /Applications/Darken the Screens (Mantra).app**

**⌃⌥⌘F1** dims **both screens at the same moment**, the MacBook's built-in to its lowest light that still lights (0.0625) and the BenQ to its lowest DDC brightness; **⌃⌥⌘F1** again brings both back to full light together. It sets the hardware brightness of every display through BetterDisplay's command line (`BetterDisplay set -tagID=… -hardwareBrightness=…`), one process per display, all started at once. The picture itself is not touched, so VNC and screen sharing see it as before. Needs BetterDisplay running (it is, from login); no Accessibility needed any more.

Marko, 2.11.2026: *"It needs to darken both display at the same time and undarken both display at the same time."*

Marko, 30.10.2026: *"build another startup called Darken the Screens. It's going to use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut again to lighten the screen to full lightness."* v2, the same day: *"emulate key pressing on the mac keyboard to darken and lighten the leds on the screen, only that."*

The window (from the star) has ON / OFF and ✕ on the first row, a button that does what the key does, and QUIT at the bottom right. Closing it leaves the app on. With `--login` (the star at login) no window opens, but the key works from the first moment. The key is a Carbon hot key: no permission needed, and the press never reaches the app in front.

```
./build.sh                    # swiftc, signed "Mantra Apps", installed in /Applications
```

From outside, without the key (tests): the distributed notification `com.mantra.darkenthescreens.toggle`.

| Document | For whom |
|---|---|
| README.md | what it is |
| TAKEOVER.md | where it stands, how to continue |
| LESSONS.md | what was learnt |
| momentaryupdates.md | Marko's requests, word for word |
