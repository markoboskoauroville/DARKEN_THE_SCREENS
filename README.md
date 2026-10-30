# Darken the Screens (Mantra)

**v2 · github.com/markoboskoauroville/DARKEN_THE_SCREENS (private) · /Applications/Darken the Screens (Mantra).app**

**⌃⌥⌘F1** presses the brightness-down key (the sun on the MacBook keyboard) to the bottom and once back up, so the screen is at its lowest light that still shows; **⌃⌥⌘F1** again presses brightness-up to full light. Only the keys are pressed (key codes 145 and 144, as the keyboard sends them): the picture itself is not touched, so VNC and screen sharing see it as before. BetterDisplay, if it takes the brightness keys, carries them on to the BenQ. Posting keys needs **Accessibility** for the app; while it is missing, an amber PERMISSIONS sits top right and opens that page of System Settings.

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
