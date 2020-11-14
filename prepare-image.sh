#!/bin/bash
# Run this to flash the SD card image.

RASPBIAN_DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2020-08-24/2020-08-20-raspios-buster-armhf-full.zip'

echo "Downloading OS image.."
wget -nc -O "raspbian.zip" "$RASBIAN_DOWNLOAD_URL"

# TODO: show options of connected file mounts and allow
# user to choose one.
DEVICE="/dev/sdX"
echo "Writing image to SD card at '$DEVICE'.."
unzip -p "raspbian.zip" | sudo dd of="$DEVICE" bs=4M conv=fsync status=progress

# TODO: populate a config.txt with WiFi settings and ssh on.
