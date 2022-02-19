#!/bin/bash
# Prerequisites: wget, unzip.
# Tested on ubuntu 20.04.
# Author: pmansour.

DOWNLOAD_URL='https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2022-01-28/2022-01-28-raspios-bullseye-arm64.zip'
TMP_ZIP_FILE=`mktemp`
IMG_OUTPUT_DIR="$HOME/raspios-img"

if [[ -d "$IMG_OUTPUT_DIR" ]]; then
    read -p "Directory '$IMG_OUTPUT_DIR' already exists. Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    echo "Removing directory '$IMG_OUTPUT_DIR'.."
    rm -rf "$IMG_OUTPUT_DIR"
fi

echo "Downloading RPI OS image to temp file.."
wget -q --show-progress "$DOWNLOAD_URL" -O "$TMP_ZIP_FILE"
echo "Extracting archive to '$IMG_OUTPUT_DIR'.."
mkdir -p "$IMG_OUTPUT_DIR"
unzip -d "$IMG_OUTPUT_DIR" "$TMP_ZIP_FILE"
rm "$TMP_ZIP_FILE"
echo "Done."
