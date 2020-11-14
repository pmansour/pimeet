#!/bin/bash
# Run this script on a pi to initialize system-wide settings.
# Must be running as root (e.g. using sudo).

set -e

## Configuration - edit as needed.
AUDIO_CARD='J370'
CHROME_FLAGS=(
  'enable-gpu-rasterization@1'
  'enable-oop-rasterization@1'
  'ignore-gpu-blacklist'
  'infinite-session-restore')
DEFAULT_USER='default'

## Constants - don't edit unless you know what you're doing.
ALSA_CONF='/usr/share/alsa/alsa.conf'
CHROME_CONFIG_FILE="/home/$DEFAULT_USER/.config/chromium/Local State"

## Package initialization
echo "Updating OS packages.."
apt-get update --quiet --assume-yes
apt-get upgrade --quiet --assume-yes

echo "Installing prerequisites.."
apt-get install --quiet --assume-yes jq

# Enable GPU in raspi-config
# Disable compositor

# Configure secure ssh.

# Create new unprivileged user

# Login as new user

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

# Set the wireless speaker as the default audio device
sed -i -E "s/^#?defaults.(pcm|ctl).card.*/defaults.\1.card $AUDIO_CARD/" "$ALSA_CONF"
