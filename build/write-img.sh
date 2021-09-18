#!/bin/bash
# Prerequisites: N/A.
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-05-07-raspios-buster-armhf-full.img"
DEVICE='/dev/sda' # Find intended device (not partition) by running `lsblk`.

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
