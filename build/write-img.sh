#!/bin/bash
# Prerequisites: N/A.
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-05-07-raspios-buster-armhf-full.img"
DEVICE='/dev/sda' # Find intended device (not partition) by running `lsblk`.

ls "$DEVICE"?* | sudo xargs -I {} ! mountpoint -q {} || umount {}

sudo dd bs=4M status=progress if="$IMG_FILE" of="$DEVICE"
