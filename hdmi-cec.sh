#!/bin/bash
# HDMI-CEC frames reference:
# https://www.cec-o-matic.com/

# TODO:
# 0. Consider putting the in/out pipes in a well
#    known location so it can be shared.
# 1. Update this script to write passive TV power
#    status to a file.
# 2. Add another systemd script to periodically
#    attempt to poll HDMI-CEC status (the previous
#    script would handle the response message). If
#    the cable is unplugged, act accordingly.

AWAITING_POWER_STATUS=0

function request_tv_power_status() {
    if [[ $AWAITING_POWER_STATUS = 1 ]]; then
        return
    fi

    echo 'Requesting power status..'
    echo '10:8f' >&${COPROC[1]}
    AWAITING_POWER_STATUS=1
}

function handle_tv_power_status() {
    AWAITING_POWER_STATUS=0
    if [[ $1 =~ "10:90:00" ]]; then
        if [[ ! $IS_ON = 1 ]]; then
            echo "TV is on."
        fi
        IS_ON=1
    elif [[ $1 =~ "10:90:11" ]]; then
        if [[ ! $IS_ON = 0 ]]; then
            echo "TV is on standby."
        fi
        IS_ON=0
    fi
}

coproc cec-client
request_tv_power_status

while IFS= read -r line <&${COPROC[0]}; do
    case "$line" in
        # TV broadcasts that it's going on standby.
        *0f:36*)
            if [[ ! $IS_ON = 0 ]]; then
                echo "TV going on standby."
            fi
            IS_ON=0
            ;;
        # TV directly requests our vendor info.
        # This usually happens when it turns on.
        *01:8c*)
            request_tv_power_status
            ;;
        # TV directly reports power status.
        *10:90*)
            handle_tv_power_status "$line"
            ;;
    esac
done
