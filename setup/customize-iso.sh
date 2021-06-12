#!/bin/bash
# Run this to customize a RaspiOS image ISO file with a given WiFi network and ssh configuration.
# NOTE -- doesn't work yet.

MOUNTED_PATH="/mnt/e"
TMP_PATH="/tmp/raspios_custom"
OUTPUT_PATH="~/raspios-custom.iso"

# Install dependencies.
echo "Installing dependencies.."
sudo apt install -qqy genisoimage
echo

# Make a working copy.
echo "Copying read-only image to temporary path.."
rm -rf "$TMP_PATH" || true
mkdir -p "$TMP_PATH"
cp -a "$MOUNTED_PATH/." "$TMP_PATH"
echo

# Configure WiFi.
echo "Configuring WiFi.."
read -p "WiFi network name: " NETWORK_NAME
read -p "WiFi network password: " NETWORK_PASS
echo

cat >"$TMP_PATH/wpa_supplicant.conf" <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="$NETWORK_NAME"
    psk="$NETWORK_PASS"
    key_mgmt=WPA-PSK
}
EOF

# Enable SSH.
echo "Configuring SSH.."
touch "$TMP_PATH/ssh"
echo

# Write the ISO back.
mkisofs -o "$OUTPUT_PATH" -b 