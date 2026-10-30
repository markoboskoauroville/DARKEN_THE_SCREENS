#!/bin/sh
# build.sh: Darken the Screens (Mantra).app, swiftc straight, no Xcode, signed "Mantra Apps", installed in /Applications.
set -e
cd "$(dirname "$0")"
V=$(sed -n 's/^let VERSION = \([0-9]*\)/\1/p' app/main.swift)
APP="build/Darken the Screens (Mantra).app"
rm -rf build; mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
swiftc -O -swift-version 5 -o "$APP/Contents/MacOS/DarkenTheScreens" app/*.swift -framework AppKit -framework Carbon
swift icon/make_icon.swift build/AppIcon.iconset && iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Darken the Screens (Mantra)</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundleIdentifier</key><string>com.mantra.darkenthescreens</string>
<key>CFBundleExecutable</key><string>DarkenTheScreens</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$V</string>
<key>CFBundleVersion</key><string>$V</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PL
codesign --force -s "Mantra Apps" "$APP"
if pgrep -xq DarkenTheScreens; then pkill -x DarkenTheScreens; sleep 1; fi
rm -rf "/Applications/Darken the Screens (Mantra).app"; cp -R "$APP" /Applications/
echo "built v$V: /Applications/Darken the Screens (Mantra).app"
