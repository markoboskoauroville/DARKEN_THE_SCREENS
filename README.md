# Screen Brightness Automatic (Mantra)

*Named Darken the Screens (Mantra) until v5; renamed by Marko on 5.11.2026, icon: black, half sun and half moon in one circle.*

**v6 · github.com/markoboskoauroville/DARKEN_THE_SCREENS (private) · /Applications/Screen Brightness Automatic (Mantra).app · built by GitHub Actions (build.yml)**

**⌃⌥⌘F1** makes **both screens completely dark, 0%**, and **⌃⌥⌘F1** again brings both to **full light, 100%**. For every display BetterDisplay knows (built-in and BenQ) it sets the hardware brightness (backlight, DDC) and BetterDisplay's software dimming to 0, and both to 1 for light (`BetterDisplay set -tagID=… -hardwareBrightness=… / -softwareBrightness=…`). The captured picture stays the same (measured), so VNC and screen sharing still see everything. Needs BetterDisplay running (from login); no Accessibility.

Marko, 2.11.2026, v5: *"not to 0%. I want complete darkness or complete lightness."*

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
