# LESSONS

- (30.10.2026) screencapture does not see gamma: it reads the frame before the gamma table. A test of the darkness therefore measures the black windows; the gamma is the second layer for his eyes, the windows the proof.
- (30.10.2026) On Apple silicon the NX media event for brightness (NSEvent systemDefined, subtype 8, NX_KEYTYPE_BRIGHTNESS_DOWN) does nothing, even from a process with the permission. A plain keyboard CGEvent with key code 145 (down) or 144 (up) works like the sun keys. Read the level with DisplayServicesGetBrightness (DisplayServices, private) to measure it.
- (30.10.2026) A press posted while ⌃⌥⌘ are still held can pick up the modifiers (⌥ with the sun key opens Displays settings). So wait until they are released, and clear the event's flags.
- (30.10.2026) v1's black windows were in the frame itself, so VNC went black too. Darkening for the eyes only means the backlight, never the picture.
- (2.11.2026) Brightness keys reach one display only (BetterDisplay sends them to the screen under the mouse). For both screens together set each directly: `BetterDisplay set -tagID=N -hardwareBrightness=x` (the app binary is the CLI); built-in is the one whose registryLocation has /disp0@. Use hardwareBrightness, never brightness, so no software dimming touches the picture.
- (2.11.2026) hardwareBrightness 0 still lights (built-in and BenQ). Complete darkness = hardwareBrightness 0 plus softwareBrightness 0; the software dimming is not in the captured frame (screencapture mean unchanged), so VNC still sees the picture.
