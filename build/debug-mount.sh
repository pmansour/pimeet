#!/bin/bash

IMG_FILE="$HOME/raspios-img/raspios-working-copy.img"
LOOP_INTERFACE=`losetup -f`
BOOT_MOUNT_PATH='/mnt/rpi/boot'
DISK_MOUNT_PATH='/mnt/rpi/disk'

echo "Mounting image '$IMG_FILE' to '$LOOP_INTERFACE'.."
sudo losetup -P "$LOOP_INTERFACE" "$IMG_FILE"

echo "Mounting boot and disk partitions.."
sudo mkdir -p "$BOOT_MOUNT_PATH"
sudo mkdir -p "$DISK_MOUNT_PATH"
sudo mount "${LOOP_INTERFACE}p1" "$BOOT_MOUNT_PATH"
sudo mount "${LOOP_INTERFACE}p2" "$DISK_MOUNT_PATH"

# ---
echo
echo "Doing some debug task.."
# Do stuff here.
# ---

echo
echo "Cleaning up mounts.."
sudo umount "$BOOT_MOUNT_PATH"
sudo umount "$DISK_MOUNT_PATH"
sudo losetup -d "$LOOP_INTERFACE"
