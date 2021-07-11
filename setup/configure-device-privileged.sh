#!/bin/bash
# Run this script on a pi to initialize system-wide settings.
# Must be running as root (e.g. using sudo).
#
# Usage (from remote machine):
# alias run-remote='scp configure-device.sh pi@raspberrypi.local:/home/pi/ && ssh pi@raspberrypi.local sudo /bin/bash /home/pi/configure-device.sh'

set -e

## Constants - don't edit unless you know what you're doing.
SSHD_CONF='/etc/ssh/sshd_config'
PRIVILEGED_USER='pi'
UNPRIVILEGED_USER='default'

## Package initialization
echo "Updating OS packages.."
sudo apt update -yqq
sudo apt upgrade -yqq
sudo apt clean -yqq

echo "Installing prerequisites.."
sudo apt install -yqq jq vim cec-utils

# Copy the picontroller to the pi.
scp -r "$PICONTROLLER_DIR" "pi@raspberrypi.local:/home/pi/src/picontroller"
# Compile the binaries and add it to the appropriate places.
pushd /home/pi/src/picontroller
go build -o ~/picontroller-creds cmd/picontroller-creds/main.go
go build -o ~/picontroller cmd/picontroller/main.go

sudo cp ~/picontroller /usr/local/bin/
sudo cp ~/picontroller-creds /usr/local/bin/

sudo chmod a+rx /usr/local/bin/picontroller
sudo chmod a+rx /usr/local/bin/picontroller-creds
popd

# Create new unprivileged user.
echo "Creating unprivileged user '$UNPRIVILEGED_USER'.."
sudo deluser default
sudo adduser --disabled-password --gecos "" "$UNPRIVILEGED_USER"

# Configure secure ssh.
sudo cp "$SSHD_CONF" "$SSHD_CONF.bak"
sudo cat >>"$SSHD_CONF" <<EOF
# New settings below.
PermitRootLogin no
AllowUsers $PRIVILEGED_USER
EOF

# Enable hardware acceleration
sudo apt install libgles2-mesa libgles2-mesa-dev xorg-dev

# Login as new user

# Enable GPU in raspi-config
# Disable compositor

# Install golang
wget -qO- https://golang.org/dl/go1.16.5.linux-armv6l.tar.gz | \
    sudo tar xzf - -C /usr/local 
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
