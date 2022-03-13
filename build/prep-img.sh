#!/bin/bash
# Prerequisites: lopsetup, mkpasswd (part of whois package), git, tree.
# Tested on ubuntu 20.04.
# Author: pmansour.

# Exit when any command fails.
set -e

IMG_FILE="$HOME/raspios-img/2022-01-28-raspios-bullseye-arm64.img"
LOOP_INTERFACE=`losetup -f`
BOOT_MOUNT_PATH='/mnt/rpi/boot'
DISK_MOUNT_PATH='/mnt/rpi/disk'
SSH_KEY_PUB="$HOME/.ssh/id_rsa.pub"
SCRIPTS_DIR="`dirname "$0"`/../scripts/"
BOOT_CONFIG_FILE="$BOOT_MOUNT_PATH/config.txt"

# $1 is context, $2 is value.
function debug {
    if [[ ! "$1" = "" ]]; then
        echo -e "\e[3m> $1:\n\e[0m" >&2
    fi
    echo -e "\e[3m$2\e[0m" >&2
}

# $1 is flag name, $2 is value.
function update_boot_config_setting() {
    sudo sed -i -E "s/^#?\s*$1=.*$/$1=$2/g" "$BOOT_CONFIG_FILE"
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
# Use @ as sed's delimiter since the hashed password may include slashes.
sudo sed -E -i "s@^pi:[^:]*:@pi:${HASHED_PASSWORD}:@" "$DISK_MOUNT_PATH/etc/shadow"
debug 'Hashed password' "`sudo cat "$DISK_MOUNT_PATH/etc/shadow" | grep -E "^pi:"`"

# Require password for sudo.
sudo sed -E -i 's/NOPASSWD://g' "$DISK_MOUNT_PATH/etc/sudoers.d/010_pi-nopasswd"
debug 'sudoers config' "`sudo cat "$DISK_MOUNT_PATH/etc/sudoers.d/010_pi-nopasswd"`"

# Configure WiFi
echo
echo "Configuring WiFi networks.."
read -p "WiFi network 1 name: " -r WIFI_NETWORK_NAME
read -p "WiFi network 1 password: " -r WIFI_NETWORK_PASSWORD

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

# Add a second WiFi network, if needed.
read -p "WiFi network 2 name: " -r WIFI_NETWORK_NAME
if [[ ! "$WIFI_NETWORK_NAME" = "" ]]; then
    read -p "WiFi network 2 password: " -r WIFI_NETWORK_PASSWORD
    cat <<EOF | sudo tee -a "$BOOT_MOUNT_PATH/wpa_supplicant.conf" >/dev/null
network={
    ssid="$WIFI_NETWORK_NAME"
    psk="$WIFI_NETWORK_PASSWORD"
    key_mgmt=WPA-PSK
}
EOF
else
    echo "Skipping second WiFi network."
fi
debug 'wpa_supplicant.conf' "`cat "$BOOT_MOUNT_PATH/wpa_supplicant.conf"`"

# Update hostname
echo
echo "Updating hostname.."
read -p "New hostname: " -r HOSTNAME
echo "$HOSTNAME" | sudo tee "$DISK_MOUNT_PATH/etc/hostname"
sudo sed -i "s/127.0.1.1.*$/127.0.1.1\t$HOSTNAME/g" "$DISK_MOUNT_PATH/etc/hosts"
debug '/etc/hostname' "`cat "$DISK_MOUNT_PATH/etc/hostname"`"
debug '/etc/hosts' "`cat "$DISK_MOUNT_PATH/etc/hosts"`"

# Set fixed screen resolution, per https://pimylifeup.com/raspberry-pi-screen-resolution/
echo
echo "Configuring screen resolution.."
update_boot_config_setting hdmi_group 1 # Group 1 (CEA) is for TVs, 2 (DMT) is for monitors.
update_boot_config_setting hdmi_mode 16 # CEA Mode 16 is 1920x1080 resolution at 60hz 16:9.

# Enable fan temperature control
echo
echo "Configuring fan at 60° on GPIO pin 14.."
FAN_GPIO=14
FAN_TEMP=60000 # 60° C in millicelcius.
# Copied from https://github.com/RPi-Distro/raspi-config/blob/de70c08c7629b2370d683193a62587ca30051e36/raspi-config#L1274
if ! sudo grep -q "dtoverlay=gpio-fan" "$BOOT_CONFIG_FILE" ; then
    if ! sudo tail -1 "$BOOT_CONFIG_FILE" | grep -q "\\[all\\]" ; then
        sudo sed "$BOOT_CONFIG_FILE" -i -e "\$a[all]"
    fi
    sudo sed "$BOOT_CONFIG_FILE" -i -e "\$adtoverlay=gpio-fan,gpiopin=$FAN_GPIO,temp=$FAN_TEMP"
else
    sudo sed "$BOOT_CONFIG_FILE" -i -e "s/^.*dtoverlay=gpio-fan.*/dtoverlay=gpio-fan,gpiopin=$FAN_GPIO,temp=$FAN_TEMP/"
fi
debug 'config.txt' "`cat "$BOOT_CONFIG_FILE" | grep 'gpio-fan'`"

# Copy files and programs.
echo
echo "Copying programs.."
GIT_TMP=`mktemp -d`
git clone -q git@github.com:pmansour/minimeet.git "$GIT_TMP/minimeet/"
sudo rm -rf "$DISK_MOUNT_PATH/usr/local/minimeet"
sudo cp -r "$GIT_TMP/minimeet/mv3/." "$DISK_MOUNT_PATH/usr/local/minimeet/"
rm -rf GIT_TMP

# Copy account creds for Chrome extension.
echo
echo "Configuring meeting credentials.."
read -p "Enter email address: " ACCOUNT_EMAIL
read -p "Enter password: " ACCOUNT_PASSWORD
sudo mkdir -p "$DISK_MOUNT_PATH/usr/local/minimeet/config"
cat <<EOF | sudo tee "$DISK_MOUNT_PATH/usr/local/minimeet/config/creds.js" >/dev/null
export const EMAIL_ADDRESS = '$ACCOUNT_EMAIL';
export const PASSWORD = '$ACCOUNT_PASSWORD';
EOF
debug 'config/creds.js' "`cat "$DISK_MOUNT_PATH/usr/local/minimeet/config/creds.js"`"
debug '' "`tree "$DISK_MOUNT_PATH/usr/local/minimeet"`"

# # Install go 1.17
# echo
# echo "Installing go 1.17.."
# wget -qO- "https://golang.org/dl/go1.17.1.linux-armv6l.tar.gz" | \
#     sudo tar xzf - -C "$DISK_MOUNT_PATH/usr/local"
# echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a "$DISK_MOUNT_PATH/home/pi/.bashrc" >/dev/null
# debug '/usr/local/go' "`ls "$DISK_MOUNT_PATH/usr/local/go"`"

# Add autostart to watch first boot progress..
echo
echo "Adding autostart for first-boot script.."
AUTOSTART_DIR="$DISK_MOUNT_PATH/home/pi/.config/autostart"
rm -rf "$AUTOSTART_DIR"
mkdir -p "$AUTOSTART_DIR"
cat <<EOF | sudo tee "$AUTOSTART_DIR/watchfirstboot.desktop" >/dev/null
[Desktop Entry]
Type=Application
Name=FirstBoot Watcher
Exec=/usr/bin/lxterminal --geometry=1000x1000 -e '/usr/bin/journalctl -fu firstboot.service'
EOF

# Finally, copy startup scripts.
echo
echo "Copying scripts.."
mkdir -p "$DISK_MOUNT_PATH/home/pi/scripts"
cp -r "$SCRIPTS_DIR" "$DISK_MOUNT_PATH/home/pi/"

# Make the main startup script run on first boot.
echo
echo "Setting up first-boot systemd service.."
SYSTEMD_SERVICES_DIR="$DISK_MOUNT_PATH/etc/systemd/system"
FIRSTBOOT_SERVICE_NAME='firstboot.service'
cat <<EOF | sudo tee "$SYSTEMD_SERVICES_DIR/$FIRSTBOOT_SERVICE_NAME" >/dev/null
[Unit]
Description=First-boot initialization script
Wants=network-online.target multi-user.target
After=multi-user.target
[Service]
Type=simple
ExecStart=/home/pi/scripts/startup.sh
[Install]
WantedBy=default.target
EOF
sudo rm -f "$SYSTEMD_SERVICES_DIR/default.target.wants/$FIRSTBOOT_SERVICE_NAME"
sudo ln -s "$SYSTEMD_SERVICES_DIR/$FIRSTBOOT_SERVICE_NAME" "$SYSTEMD_SERVICES_DIR/default.target.wants/$FIRSTBOOT_SERVICE_NAME"

# Add a service for turning off the TV on shutdown.
echo
echo "Setting up TV standby systemd service.."
STANDBY_SERVICE_NAME='tv-standby.service'
cat <<EOF | sudo tee "$SYSTEMD_SERVICES_DIR/$STANDBY_SERVICE_NAME" >/dev/null
[Unit]
Description=Puts a connected TV on standby when on system shut down.

[Service]
Type=oneshot
RemainAfterExit=true
ExecStop=/home/pi/scripts/tv-standby.sh

[Install]
WantedBy=default.target
EOF
sudo rm -f "$SYSTEMD_SERVICES_DIR/default.target.wants/$STANDBY_SERVICE_NAME"
sudo ln -s "$SYSTEMD_SERVICES_DIR/$STANDBY_SERVICE_NAME" "$SYSTEMD_SERVICES_DIR/default.target.wants/$STANDBY_SERVICE_NAME"


# Final touchups.
echo
debug '' "`tree "$DISK_MOUNT_PATH/home/pi"`"

echo
echo "Done."
