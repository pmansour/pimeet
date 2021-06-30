#!/bin/bash
# Run this script on a pi to initialize system-wide settings.
# Must be running as root (e.g. using sudo).
#
# Usage (from remote machine):
# alias run-remote='scp configure-device.sh pi@raspberrypi.local:/home/pi/ && ssh pi@raspberrypi.local sudo /bin/bash /home/pi/configure-device.sh'

set -e
