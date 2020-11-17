#!/bin/bash
# Run this to flash the SD card image.
# Note: this doesn't work in WSL2 due to lack of USB device passthrough.

# RASPBIAN_DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2020-08-24/2020-08-20-raspios-buster-armhf-full.zip'

# echo "Downloading OS image.."
# wget -nc -O "raspbian.zip" "$RASBIAN_DOWNLOAD_URL"

# # TODO: show options of connected file mounts and allow
# # user to choose one.
# DEVICE="/dev/sdX"
# echo "Writing image to SD card at '$DEVICE'.."
# unzip -p "raspbian.zip" | sudo dd of="$DEVICE" bs=4M conv=fsync status=progress

# Configure WiFi.
BOOT_DIR="/mnt/d"
read -p "WiFi network name: " NETWORK_NAME
read -p "WiFi network password: " -s NETWORK_PASS
echo

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
touch "$BOOT_DIR/ssh"
