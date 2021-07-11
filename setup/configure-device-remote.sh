#!/bin/bash

INIT_USERNAME='pi'
INIT_PASSWORD='raspberry'
HOSTNAME='raspberrypi.local'
SETUP_SCRIPT='configure-device-privileged.sh'
REMOTE_DIR='/home/pi'

TARGET="$INIT_USERNAME@$HOSTNAME"

scp "$SETUP_SCRIPT" "$TARGET:$REMOTE_DIR"
ssh "$TARGET" /bin/bash "$REMOTE_DIR/$SETUP_SCRIPT"
