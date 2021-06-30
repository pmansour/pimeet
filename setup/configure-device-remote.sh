#!/bin/bash

INIT_USERNAME='pi'
INIT_PASSWORD='raspberry'
HOSTNAME='raspberrypi.local'
PAYLOAD='configure-device-privileged.sh'
REMOTE_DIR='/home/pi'

TARGET="$INIT_USERNAME@$HOSTNAME"

scp "$PAYLOAD" "$TARGET:$REMOTE_DIR"
ssh "$TARGET" /bin/bash "$REMOTE_DIR/$PAYLOAD"
