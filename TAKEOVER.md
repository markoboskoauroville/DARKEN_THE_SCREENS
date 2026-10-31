# TAKEOVER

**31.10.2026, v3: ON · OFF · TOP · ✕.** Marko: *"Each needs to have the same user interface elements. On, off and top"*. TOP beside ✕ on the window (green = `.floating`, UserDefaults `onTop`, applied at launch); OFF, TOP, PERMISSIONS, ✕ are Accessibility buttons (`off`, `top`, `permissions`, `close`); the bottom QUIT removed. `DarkenTheScreens --shot <png>` renders the window off screen at minimum size and prints the identifiers. Note: build.sh still ends the running copy with `pkill -x` (SIGTERM); quit it first (`osascript … to quit` works; at `--login` there is no window for AX).

**30.10.2026, v2.** The darkness model of v1 (gamma to zero and black windows above everything) blacked out VNC as well. Marko asked for the brightness keys instead. v2 presses key code 145 (brightness down) sixteen times and 144 (up) once to darken, and 144 sixteen times to light. Built and installed. Measured from the shell: one press of 145 took the built-in display from 1.000 to 0.918, and 144 put it back.

**Waiting:** Marko gives the app Accessibility (PERMISSIONS in its window, or System Settings → Privacy & Security → Accessibility → Darken the Screens). Without it the presses are dropped silently. After that, his own press of ⌃⌥⌘F1, and whether the BenQ follows through BetterDisplay.
