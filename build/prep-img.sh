#!/bin/bash
# Prerequisites: lopsetup, mkpasswd (part of whois package).
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-05-07-raspios-buster-armhf-full.img"
LOOP_INTERFACE=`losetup -f`
BOOT_MOUNT_PATH='/mnt/rpi/boot'
DISK_MOUNT_PATH='/mnt/rpi/disk'
SSH_KEY_PUB="$HOME/.ssh/id_rsa.pub"

# $1 is context, $2 is value.
function debug {
    echo -e "\e[3m> $1:\n$2\e[0m" >&2
}

function setup_mounts {
    echo "Mounting image '$IMG_FILE' to '$LOOP_INTERFACE'.."
    sudo losetup -P "$LOOP_INTERFACE" "$IMG_FILE"

    echo "Mounting boot and disk partitions.."
    sudo mkdir -p "$BOOT_MOUNT_PATH"
    sudo mkdir -p "$DISK_MOUNT_PATH"
    sudo mount "${LOOP_INTERFACE}p1" "$BOOT_MOUNT_PATH"
    sudo mount "${LOOP_INTERFACE}p2" "$DISK_MOUNT_PATH"
}
function cleanup_mounts {
    echo
    echo "Cleaning up mounts.."
    sudo umount "$BOOT_MOUNT_PATH"
    sudo umount "$DISK_MOUNT_PATH"
    sudo losetup -d "$LOOP_INTERFACE"
}

setup_mounts
trap cleanup_mounts EXIT

# Force key-based auth with SSH.
echo
echo "Configuring key-based SSH access.."
sudo touch "$BOOT_MOUNT_PATH/ssh"
sudo sed -E -i 's/^#?PasswordAuthentication (yes|no)$/PasswordAuthentication no/g' "$DISK_MOUNT_PATH/etc/ssh/sshd_config"
sudo sed -E -i 's/^#?PermitRootLogin .*$/PermitRootLogin no/g' "$DISK_MOUNT_PATH/etc/ssh/sshd_config"
debug 'sshd_config' "`cat "$DISK_MOUNT_PATH/etc/ssh/sshd_config" | grep -E "(^#?PasswordAuthentication)|(^#?PermitRootLogin)"`"

mkdir -p "$DISK_MOUNT_PATH/home/pi/.ssh"
cat "$SSH_KEY_PUB" > "$DISK_MOUNT_PATH/home/pi/.ssh/authorized_keys"
sudo chown 1000:1000 "$DISK_MOUNT_PATH/home/pi/.ssh/authorized_keys"
debug '~/.ssh/authored_keys' "`cat "$DISK_MOUNT_PATH/home/pi/.ssh/authorized_keys"`"

# Change default password for 'pi' user.
echo
echo "Changing password for 'pi' user.."
NEW_PASSWORD=`mkpasswd -5`
# Use _ as sed's delimiter since the hashed password may include slashes.
sudo sed -E -i "s@^pi:[^:]+:@pi:${NEW_PASSWORD}:@" "$DISK_MOUNT_PATH/etc/shadow"
debug 'Hashed password' "`sudo cat "$DISK_MOUNT_PATH/etc/shadow" | grep -E "^pi:"`"

# Configure WiFi
echo
echo "Configuring WiFi.."
read -p "WiFi network name: " -r WIFI_NETWORK_NAME
read -p "WiFi network password: " -r WIFI_NETWORK_PASSWORD

cat <<EOF | sudo sudo tee "$BOOT_MOUNT_PATH/wpa_supplicant.conf" >/dev/null
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={
    ssid="$WIFI_NETWORK_NAME"
    psk="$WIFI_NETWORK_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
debug 'wpa_supplicant.conf' "`cat "$BOOT_MOUNT_PATH/wpa_supplicant.conf"`"

# Enable hardware accelaration
echo
echo "Configuring hardware accelaration.."
sudo sed "$BOOT_MOUNT_PATH/config.txt" -i -e "s/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g"
sudo sed "$BOOT_MOUNT_PATH/config.txt" -i -e "s/^#dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d/g"
debug 'config.txt' "`cat "$BOOT_MOUNT_PATH/config.txt" | grep -E '^#?dtoverlay=vc4'`"

# TODO:
# 1. Prompt for new root password, copy that into img.
