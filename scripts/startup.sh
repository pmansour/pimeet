#!/bin/bash
# Script to be run interactively on first login.

if [[ "`id -u`" -ne 0 ]]; then
    echo "This script must be run as root. Try running 'sudo $1'."
    exit 1
fi

echo "Waiting for system to load.."
sleep 15s

echo "Updating packages.."
apt-get update
apt-get upgrade --yes

# Configure autologin.
echo
echo "Configuring autologin.."
apt-get install --yes --quiet lightdm
# See https://github.com/RPi-Distro/raspi-config/blob/master/raspi-config#L1339
systemctl set-default graphical.target
ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I \$TERM
EOF
sed /etc/lightdm/lightdm.conf -i -e "s/^\(#\|\)autologin-user=.*/autologin-user=pi/"

# Enable VNC server.
echo
echo "Installing and enabling VNC server.."
apt-get install --yes --quiet realvnc-vnc-server
systemctl enable vncserver-x11-serviced.service && \
    systemctl start vncserver-x11-serviced.service

# Update the locale and timezone.
echo
echo "Updating locale and timezone.."
LOCALE='en_US.UTF-8'
ENCODING='UTF-8'
sed -E -i 's/^\s*#?\s*en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/' '/etc/locale.gen'
sed -i "s/^\s*LANG=\S*/LANG=en_US.UTF-8/" '/etc/default/locale'
dpkg-reconfigure -f noninteractive locales

TIMEZONE='US/Pacific'
rm /etc/localtime
echo "$TIMEZONE" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Install other useful tools
apt-get install --yes --quiet vim stress-ng
apt-get install --yes --quiet cec-utils # Needed by TV standby service.

# Remove useless stuff that's still present
apt-get autoremove --yes --quiet

# Add autostart entries
echo
echo "Adding autostart for choosing default audio sink.."
AUTOSTART_DIR="/home/pi/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
cat <<EOF | sudo tee "$AUTOSTART_DIR/default-audio-sink.desktop" >/dev/null
[Desktop Entry]
Type=Application
Name=Default audio sink selector
Exec=/home/pi/scripts/set-default-audio-sink.sh
EOF

echo "Adding autostart for chromium.."
cat <<EOF | sudo tee "$AUTOSTART_DIR/chromium.desktop" >/dev/null
[Desktop Entry]
Type=Application
Name=Chromium
Exec=/home/pi/scripts/start-chromium.sh
EOF
# Create a copy on the Desktop that can easily be double-clicked interactively.
mkdir -p "/home/pi/Desktop"
rm -f "/home/pi/Desktop/chromium.desktop"
cp "$AUTOSTART_DIR/chromium.desktop" "/home/pi/Desktop/chromium.desktop"

# Firstboot watcher service is no longer relevant after this.
echo
echo "Removing FirstBoot watcher application.."
rm -f "$AUTOSTART_DIR/watchfirstboot.desktop"

echo
echo "Enabling the TV lifecycle service.."
systemctl enable tv-lifecycle.serice

# Install ArgonOne tools
echo
echo "Installing ArgonOne tools.."
curl https://download.argon40.com/argon1.sh | bash

# Configure ArgonOne fan speeds
cat <<EOF | sudo tee "/etc/argononed.conf" >/dev/null
#
# Argon One Fan Speed Configuration
#
# Min Temp=Fan Speed
55=25
60=75
65=100
EOF

echo
echo "Disabling first-boot systemd service.."
rm -f "/etc/systemd/system/default.target.wants/firstboot.service"

echo
echo "Don't forget to run argonone-ir"
echo "Done."

# TODO: reboot when this is finished.
echo "Rebooting now.."
reboot
