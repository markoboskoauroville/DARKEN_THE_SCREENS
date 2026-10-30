# Darken the Screens (Mantra)

**v1 · github.com/markoboskoauroville/DARKEN_THE_SCREENS (private) · /Applications/Darken the Screens (Mantra).app**

**⌃⌥⌘F1** darkens every screen to complete darkness; **⌃⌥⌘F1** again brings them back to full light. Dark means every display's gamma goes to zero (the picture and the cursor) and a black window covers each screen above everything, so a display that ignores gamma goes dark as well. Light gives the displays their own colour settings back and the windows fade away (0.4 s each way). If the app ends while the screens are dark, macOS gives the gamma back by itself.

Marko, 30.10.2026: *"build another startup called Darken the Screens. It's going to use the shortcut key Control + Option + Command + F1 to darken both screens to complete darkness, and the same shortcut again to lighten the screen to full lightness."*

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
