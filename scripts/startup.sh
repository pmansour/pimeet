#!/bin/bash
# Script to be run interactively on first login.

if [[ "`id -u`" -ne 0 ]]; then
    echo "This script must be run as root. Try running 'sudo $1'."
    exit 1
fi

# Necessary hack to re-enable WiFi in RPI-OS bullseye.
echo "Unblocking WiFi.."
rfkill unblock wlan

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

# # Configure HDMI-CEC
# echo
# echo "Configuring HDMI-CEC.."
# apt-get install --yes --quiet cec-utils

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

# # Install graphics accelaration libraries.
# echo
# echo "Installing graphics libraries.."
# apt-get install --yes --quiet libgles2-mesa libgles2-mesa-dev xorg-dev

# Installing other useful tools
apt-get install --yes --quiet vim stress-ng

# Remove useless stuff that's still present
apt-get autoremove --yes --quiet

# Install argonone tools
echo
echo "Installing argonone tools.."
curl https://download.argon40.com/argon1.sh | bash

echo
echo "Disabling first-boot systemd service.."
SYSTEMD_SERVICE_NAME='firstboot.service'
if [[ -f "/etc/systemd/system/multi-user.target.wants/$SYSTEMD_SERVICE_NAME" ]]; then
    rm -rf "/etc/systemd/system/multi-user.target.wants/$SYSTEMD_SERVICE_NAME"
fi

echo
echo "Don't forget to run argonone-config and argonone-ir"
echo "Done."
