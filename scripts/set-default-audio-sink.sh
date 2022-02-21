#!/bin/bash

# Audio sinks to set as default, in order of preference. Should be lowercase.
ORDERED_PREFERENCES=("jabra" "hdmi" "bcm2835")

LOG_FILE="$HOME/logs/set-default-audio-sink.log"
mkdir -p "$(dirname "$LOG_FILE")"
function write_log {
    echo "$(date) | $@" >> "$LOG_FILE"
}

# Choose one of the available sinks according to preference.
NUMBERED_SINK_NAMES="$(XDG_RUNTIME_DIR=/run/user/1000 pacmd list-sinks | grep -E -e index -e '\s+name:.*' | sed -E 'N;s/^\s*\*?\s*index: ([0-9]+)\n\s*name: (.*)/\1 \2/g')"
for pref in "${ORDERED_PREFERENCES[@]}"; do
    if [[ "${NUMBERED_SINK_NAMES,,}" =~ "$pref" ]]; then
        CHOSEN_SINK="$(echo "$NUMBERED_SINK_NAMES" | grep -i "$pref" | sed -E 's/^([0-9]+).*$/\1/')"
        break
    fi
done

if [[ "CHOSEN_SINK" = "" ]]; then
    write_log "No suitable sink was found."
    exit 1
fi

write_log "Chosen sink is: '$CHOSEN_SINK'."
write_log "$(XDG_RUNTIME_DIR=/run/user/1000 pactl set-default-sink "$CHOSEN_SINK" 2>&1)"
