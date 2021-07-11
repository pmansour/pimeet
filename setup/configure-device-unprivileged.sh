#!/bin/bash
# Run this script on a pi to initialize user settings for unprivileged user.
# Must be running as default user.
#
# Usage (from remote machine):
# scp configure-device-unprivileged.sh default@raspberrypi.local:/home/default/ && ssh default@raspberrypi.local sudo /bin/bash /home/default/configure-device-unprivileged.sh

set -e

## Constants - don't edit unless you know what you're doing.
PICONTROLLER_DIR='~/src/picontroller'
UNPRIVILEGED_USER='default'

# Add go to the path.
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# go get github.com/pmansour/picontroller/picontroller

