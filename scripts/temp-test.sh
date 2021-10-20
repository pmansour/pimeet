#!/bin/bash
# Runs a stress test while displaying the current temperature.

# Stop printing temperature when script exits.
(while true; do /usr/bin/vcgencmd measure_temp; sleep 1; done)&
RUNNING_PID=$!
trap "kill -kill $RUNNING_PID" EXIT

/usr/bin/stress-ng --cpu 0 --cpu-method fft
