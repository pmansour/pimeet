#!/bin/bash
# Run this script on a pi to initialize system-wide settings.
# Must be running as root (e.g. using sudo).

set -e

## Configuration - edit as needed.
AUDIO_CARD='J370'

## Constants - don't edit unless you know what you're doing.
ALSA_CONF='/usr/share/alsa/alsa.conf'
SSHD_CONF='/etc/ssh/sshd_config'

read -p "Device IP address: " DEVICE_IP
read -p "New privileged user name: " PRIVILEGED_USER

## Package initialization
echo "When prompted, enter the password 'raspberry'."
echo

ssh -t "pi@$DEVICE_IP" /bin/bash <<EOF_OUTER
set -e

echo
# echo "Updating OS packages.."
# sudo apt update --assume-yes #  --quiet
# sudo apt upgrade --assume-yes
# sudo apt clean --assume-yes

# echo "Installing prerequisites.."
# sudo apt-get install --assume-yes jq

# Create new privileged user.

# echo "Creating privileged user '$PRIVILEGED_USER'.."
# sudo adduser "$PRIVILEGED_USER"

echo "Adding user to groups.."
groups pi | sed 's/^pi : pi //' | tr ' ' ',' | xargs -i% \
    sudo usermod -a -G % "$PRIVILEGED_USER"

echo "Updating user password.."
sudo passwd "$PRIVILEGED_USER"

# Configure secure ssh.
sudo cp "$SSHD_CONF" "$SSHD_CONF.bak"
sudo cat >>"$SSHD_CONF" <<EOF
# New settings below.
PermitRootLogin no
AllowUsers $PRIVILEGED_USER
EOF
EOF_OUTER

# Create new unprivileged user

# Login as new user

# Enable GPU in raspi-config
# Disable compositor

# Set the wireless speaker as the default audio device
sed -i -E "s/^#?defaults.(pcm|ctl).card.*/defaults.\1.card $AUDIO_CARD/" "$ALSA_CONF"
