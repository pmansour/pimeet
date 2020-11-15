#!/bin/bash
# Run this script on a pi to initialize system-wide settings.
# Must be running as root (e.g. using sudo).

set -e

## Configuration - edit as needed.
AUDIO_CARD='J370'

## Constants - don't edit unless you know what you're doing.
ALSA_CONF='/usr/share/alsa/alsa.conf'

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

# Set the wireless speaker as the default audio device
sed -i -E "s/^#?defaults.(pcm|ctl).card.*/defaults.\1.card $AUDIO_CARD/" "$ALSA_CONF"
