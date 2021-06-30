#!/bin/bash
# Run this script on a pi to initialize user settings for unprivileged user.
# Must be running as default user.
#
# Usage (from remote machine):
# scp configure-device-unprivileged.sh default@raspberrypi.local:/home/default/ && ssh default@raspberrypi.local sudo /bin/bash /home/default/configure-device-unprivileged.sh

set -e

