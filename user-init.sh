#!/bin/bash
# Run this script on a pi to initialize user-level settings.
# Should be running as the local user (not root).

set -e

## Configuration - edit as needed.
CHROME_FLAGS=(
  'enable-gpu-rasterization@1'
  'enable-oop-rasterization@1'
  'ignore-gpu-blacklist'
  'infinite-session-restore')

## Constants - don't edit unless you know what you're doing.
CHROME_BIN='/usr/bin/chromium-browser'
CHROME_CONFIG_FILE="$HOME/.config/chromium/Local State"
AUTOSTART_DIR="$HOME/.config/autostart"

# Set Chrome flags
for FLAG in ${CHROME_FLAGS[@]}; do
  if cat "$CHROME_CONFIG_FILE" | jq '.browser.enabled_labs_experiments' | grep -q "$FLAG"; then
    echo "Chromium experiment '$FLAG' is already enabled."
  else
    echo "Enabling Chromium experiment '$FLAG'.."
    NEW_CONTENT="$(cat "$CHROME_CONFIG_FILE" | jq '.browser.enabled_labs_experiments += ["'"$FLAG"'"]')"
    echo "$NEW_CONTENT" > "$CHROME_CONFIG_FILE"
  fi
done
# Login to Chrome

# Add the neccessary autostart applications.
echo "Writing autostart applications.."
mkdir -p "$AUTOSTART_DIR"
tee "$AUTOSTART_DIR/chrome.desktop" >&2 << EOF
[Desktop Entry]
Type=Application
Name=Chromium
Exec=$CHROME_BIN --start-fullscreen
EOF

tee "$AUTOSTART_DIR/max-resolution.desktop" >&2 << EOF
[Desktop Entry]
Type=Application
Name=Reduce max resolution
Exec=xrandr --output HDMI-1 --mode 2560x1440
EOF

echo "Done! Please login to Chrome."
