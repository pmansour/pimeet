#!/bin/bash
# Prerequisites: lopsetup, mkpasswd (part of whois package), git, tree.
# Tested on ubuntu 20.04.
# Author: pmansour.

IMG_FILE="$HOME/raspios-img/2021-05-07-raspios-buster-armhf-full.img"
LOOP_INTERFACE=`losetup -f`
BOOT_MOUNT_PATH='/mnt/rpi/boot'
DISK_MOUNT_PATH='/mnt/rpi/disk'
SSH_KEY_PUB="$HOME/.ssh/id_rsa.pub"
STARTUP_SCRIPT="`dirname "$0"`/../scripts/startup.sh"

# $1 is context, $2 is value.
function debug {
    if [[ ! "$1" = "" ]]; then
        echo -e "\e[3m> $1:\n\e[0m" >&2
    fi
    echo -e "\e[3m$2\e[0m" >&2    
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
read -p "Enter new password: " PASSWD
HASHED_PASSWORD=`mkpasswd -5 "$PASSWD"`
PASSWD='' # Clear password, just in case.
# Use _ as sed's delimiter since the hashed password may include slashes.
sudo sed -E -i "s@^pi:[^:]+:@pi:${HASHED_PASSWORD}:@" "$DISK_MOUNT_PATH/etc/shadow"
debug 'Hashed password' "`sudo cat "$DISK_MOUNT_PATH/etc/shadow" | grep -E "^pi:"`"

# Configure WiFi
echo
echo "Configuring WiFi.."
read -p "WiFi network name: " -r WIFI_NETWORK_NAME
read -p "WiFi network password: " -r WIFI_NETWORK_PASSWORD

cat <<EOF | sudo tee "$BOOT_MOUNT_PATH/wpa_supplicant.conf" >/dev/null
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

# Update hostname
echo
echo "Updating hostname.."
read -p "New hostname: " -r HOSTNAME
echo "$HOSTNAME" | sudo tee "$DISK_MOUNT_PATH/etc/hostname"
sudo sed -i "s/127.0.1.1.*$/127.0.1.1\t$HOSTNAME/g" "$DISK_MOUNT_PATH/etc/hosts"
debug '/etc/hostname' "`cat "$DISK_MOUNT_PATH/etc/hostname"`"
debug '/etc/hosts' "`cat "$DISK_MOUNT_PATH/etc/hosts"`"

# Enable hardware accelaration
echo
echo "Configuring hardware accelaration.."
sudo sed "$BOOT_MOUNT_PATH/config.txt" -i -e "s/^dtoverlay=vc4-kms-v3d/#dtoverlay=vc4-kms-v3d/g"
sudo sed "$BOOT_MOUNT_PATH/config.txt" -i -e "s/^#dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d/g"
debug 'config.txt' "`cat "$BOOT_MOUNT_PATH/config.txt" | grep -E '^#?dtoverlay=vc4'`"

# Copy files and programs.
echo
echo "Copying programs.."
GIT_TMP=`mktemp -d`
git clone -q git@github.com:pmansour/minimeet.git "$GIT_TMP/minimeet/"
# TODO: move to a GitHub release, or use go's mod system for this.
# git clone -q git@github.com:pmansour/picontroller.git "$GIT_TMP/picontroller/"
mkdir -p "$DISK_MOUNT_PATH/home/pi/src"
cp -r "$GIT_TMP/minimeet/src2/." "$DISK_MOUNT_PATH/home/pi/src/minimeet/"
#cp -r "$GIT_TMP/picontroller/." "$DISK_MOUNT_PATH/home/pi/src/picontroller/"
rm -rf GIT_TMP

# Copy account creds for Chrome extension.
echo
echo "Configuring meeting credentials.."
read -p "Enter email address: " ACCOUNT_EMAIL
read -p "Enter password: " ACCOUNT_PASSWORD
mkdir -p "$DISK_MOUNT_PATH/home/pi/src/minimeet/config"
cat <<EOF | sudo tee "$DISK_MOUNT_PATH/home/pi/src/minimeet/config/creds.js" >/dev/null
const EMAIL_ADDRESS = '$ACCOUNT_EMAIL';
const PASSWORD = '$ACCOUNT_PASSWORD';
EOF
debug 'config/creds.js' "`cat "$DISK_MOUNT_PATH/home/pi/src/minimeet/config/creds.js"`"

# Finally, copy the startup script.
echo
echo "Copying startup script.."
cp "$STARTUP_SCRIPT" "$DISK_MOUNT_PATH/home/pi/"

# Final touchups.
echo
rm -rf "$DISK_MOUNT_PATH/home/pi/Bookshelf"
debug '' "`tree "$DISK_MOUNT_PATH/home/pi"`"

echo
echo "Done."
