#!/bin/bash
# Sends a signal to the TV over HDMI-CEC telling it to make this device the active source. This should also turn the TV on.

echo 'as' | cec-client -s -d 1
