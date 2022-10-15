#!/bin/bash
# Prerequisites: wget, xz (part of xz-utils).
# Tested on ubuntu 20.04.
# Author: pmansour.

DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64.img.xz'
IMG_OUTPUT_DIR="$HOME/raspios-img"
TMP_DOWNLOADED_FILE="$IMG_OUTPUT_DIR/$(basename "$DOWNLOAD_URL")"

set -e

if [[ -d "$IMG_OUTPUT_DIR" ]]; then
    read -p "Directory '$IMG_OUTPUT_DIR' already exists. Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

mkdir -p "$IMG_OUTPUT_DIR"

echo "Downloading RPI OS image to temp file.."
wget -q --show-progress "$DOWNLOAD_URL" -O "$TMP_DOWNLOADED_FILE"
echo "Extracting archive to '$IMG_OUTPUT_DIR'.."
xz -dvf "$TMP_DOWNLOADED_FILE"

echo "Done."
