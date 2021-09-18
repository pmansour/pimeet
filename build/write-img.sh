#!/bin/bash
# Prerequisites: N/A.
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-05-07-raspios-buster-armhf-full.img"
# Find intended device (not partition) by running `lsblk`.
DEVICE='/dev/sda'

PARTITIONS=(`sudo fdisk -l "$DEVICE" | grep "^${DEVICE}" | cut -d' ' -f1`)
echo "Partitions found: ${PARTITIONS[*]}"
echo "Unmounting partitions ${PARTITIONS[*]}.."
ls "$DEVICE"?* | sudo xargs -I {} ! mountpoint -q {} || umount {}
# sudo umount "${DEVICE}?*"
# for partition in "${PARTITIONS[*]}"; do
#     sudo umount "$PARTITION"
# done

sudo dd bs=4M status=progress if="$IMG_FILE" of="$DEVICE"
