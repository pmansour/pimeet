#!/bin/bash
# Sends a signal to the TV over HDMI-CEC that it should go on standby.

echo 'standby 0.0.0.0' | cec-client -s -d 1
