#!/bin/bash

/usr/bin/chromium-browser \
    --enable-gpu-rasterization \
    --enable-oop-rasterization \
    --enable-accelerated-video-decode \
    --ignore-gpu-blocklist \
    --start-fullscreen \
    --disable-session-crashed-bubble \
    --load-extension=/usr/local/minimeet \
    "https://accounts.google.com/signin/v2?continue=https%3A%2F%2Fmeet.google.com"
