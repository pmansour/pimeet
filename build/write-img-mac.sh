#!/bin/bash
# Prerequisites: Docker
# Tested on MacOS 12.2.1
# Author: behoyh

# NOTE: EXPERIMENTAL. Use at your own risk!
# Requires Dockerfile to have written .iso image first, eg.
# docker run -it -v /dev:/dev -v $HOME/raspios-img/output/:/root/raspios-img/ --privileged pimeet
# where '$HOME/raspios-img/output/' is the location of the image.

IMG_FILE="$HOME/raspios-img/output/2022-01-28-raspios-bullseye-arm64.img"
DEVICE='/dev/rdisk5'  # Find intended device (not partition) by running `diskutil list`.
                      # Should look something like '/dev/disk5' for a USB adapter, or '/dev/disk6' for a native SD card slot.

diskutil unmountDisk ${DEVICE}

# press CONTROL + T while executing to see progress
sudo dd if=${IMG_FILE} of=${DEVICE} bs=1m