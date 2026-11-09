# TAKEOVER

**5.11.2026, v6: Screen Brightness Automatic (Mantra).** Renamed by Marko; icon black, one circle half sun half moon
(STAR_SWIFT icons6 symbol `sunmoon`, letters SCR BRI). Bundle id and the toggle notification keep the old name
(com.mantra.darkenthescreens) so permissions and the star switch stay. First GitHub Actions build (.github/workflows/build.yml).


**2.11.2026, v5: 0% and 100%.** Marko: v4 followed on both screens but not to 0%. v5 sets hardwareBrightness AND softwareBrightness to 0 on every display (1 for light). Tested: dark 0/0 on both, light 1/1 on both; screencapture mean before and while dark the same (83.2), so VNC keeps the picture. **Confirmed by Marko** (2.11.2026): "yes, baba, it's perfect". Nothing waiting.

**2.11.2026, v4: both screens together.** The sun keys of v2/v3 reached only the display BetterDisplay handed them to, so one screen dimmed and the other not. v4 lists the displays (`BetterDisplay get -identifiers`) and sets `-hardwareBrightness` on each at once: built-in 0.0625, BenQ 0, light 1.0 for both. Tested through the toggle notification: before 1.0/1.0, dark 0.063/0.0, light 1.0/1.0. No more key presses, so no Accessibility; PERMISSIONS shows only if BetterDisplay is missing. **Waiting:** his own ⌃⌥⌘F1 and the star's row.

**31.10.2026, v3: ON · OFF · TOP · ✕.** Marko: *"Each needs to have the same user interface elements. On, off and top"*. TOP beside ✕ on the window (green = `.floating`, UserDefaults `onTop`, applied at launch); OFF, TOP, PERMISSIONS, ✕ are Accessibility buttons (`off`, `top`, `permissions`, `close`); the bottom QUIT removed. `DarkenTheScreens --shot <png>` renders the window off screen at minimum size and prints the identifiers. Note: build.sh still ends the running copy with `pkill -x` (SIGTERM); quit it first (`osascript … to quit` works; at `--login` there is no window for AX).

**30.10.2026, v2.** The darkness model of v1 (gamma to zero and black windows above everything) blacked out VNC as well. Marko asked for the brightness keys instead. v2 presses key code 145 (brightness down) sixteen times and 144 (up) once to darken, and 144 sixteen times to light. Built and installed. Measured from the shell: one press of 145 took the built-in display from 1.000 to 0.918, and 144 put it back.

**Waiting:** Marko gives the app Accessibility (PERMISSIONS in its window, or System Settings → Privacy & Security → Accessibility → Darken the Screens). Without it the presses are dropped silently. After that, his own press of ⌃⌥⌘F1, and whether the BenQ follows through BetterDisplay.


## From the former README (9.11.2026)

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

## v10 (9.11.2026)
⌃⌥⌘F1 starts G815 Lights if it is not running (open -g, full path, up to 5 s), sends NIGHT/DAY, waits for the ack notification community.auroville.g815lights.night.ack, restarts G815 Lights once if no ack; every step logged to ~/.darken/log.txt. Pairs with G815 Lights v32.
