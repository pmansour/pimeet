#!/bin/bash
# Run this to flash the SD card image.
# Note: this doesn't work in WSL2 due to lack of USB device passthrough.

RASPBIAN_DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2020-08-24/2020-08-20-raspios-buster-armhf-full.zip'

echo "Downloading OS image.."
wget -nc -O "raspbian.zip" "$RASBIAN_DOWNLOAD_URL"

# TODO: show options of connected file mounts and allow
# user to choose one.
DEVICE="/dev/sdX"
echo "Writing image to SD card at '$DEVICE'.."
unzip -p "raspbian.zip" | sudo dd of="$DEVICE" bs=4M conv=fsync status=progress

# Configure WiFi.
SD_MOUNT_POINT='/mnt/foo'
BOOT_DIR="$SD_MOUNT_POINT/boot"
read -p "WiFi network name: " NETWORK_NAME
read -p "WiFi network password: " -s NETWORK_PASS

tee "$BOOT_DIR/wpa_supplicant.conf" >&2 < EOF
network={
    ssid="$NETWORK_NAME"
    psk="$NETWORK_PASS"
    key_mgmt=WPA-PSK
}
EOF

# Enable SSH.
touch "$BOOT_DIR/ssh"
