#!/bin/bash
# Prerequisites: N/A.
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-10-30-raspios-bullseye-armhf.img"
DEVICE='/dev/mmcblk0' # Find intended device (not partition) by running `lsblk`.
                      # SHould look something like '/dev/sda' for a USB adapter, or '/dev/mmcblk0' for a native SD card slot.

function confirm_device() {
    sudo fdisk -l "$DEVICE"
    echo
    read -p "Confirm formatting device '$DEVICE'? [y/N] " -n 1 -r
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
}

confirm_device
ls "$DEVICE"?* | sudo xargs umount -q
sudo dd bs=4M status=progress if="$IMG_FILE" of="$DEVICE"
ls "$DEVICE"?* | sudo xargs umount -q

echo
echo "Done."
