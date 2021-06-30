#!/bin/bash
# Run this to configure a mounted SD card with RaspiOS for first-run.
# Pre-requisite: SD card must be mounted to $BOOT_DIR.

BOOT_DIR="/mnt/e"

# Configure WiFi.
read -p "WiFi network name: " NETWORK_NAME
read -p "WiFi network password: " NETWORK_PASS

echo "Configuring WiFi.."
cat >"$BOOT_DIR/wpa_supplicant.conf" <<EOF
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
echo "Enabling SSH.."
touch "$BOOT_DIR/ssh"

# Enable hardware-acceleration
sed "$BOOT_DIR/config.txt" -i -e "s/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g"
sed "$BOOT_DIR/config.txt" -i -e "s/^#dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d/g"
