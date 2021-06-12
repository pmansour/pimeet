#!/bin/bash
# Run this to flash the SD card image.
# Note: this doesn't work in WSL2 due to lack of USB device passthrough.

RASPIOS_DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_full_armhf/images/raspios_full_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-full.zip'

echo "Downloading OS image.."
wget -nc -O "raspbian.zip" "$RASPIOS_DOWNLOAD_URL"

# TODO: show options of connected file mounts and allow
# user to choose one.
DEVICE="/dev/sdX"
echo "Writing image to SD card at '$DEVICE'.."
unzip -p "raspbian.zip" | sudo dd of="$DEVICE" bs=4M conv=fsync status=progress
