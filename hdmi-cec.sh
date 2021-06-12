#!/bin/bash
# HDMI-CEC frames reference:
# https://www.cec-o-matic.com/

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

pattern=("01:44:01" "01:44:02" "01:44:03" "01:44:04" "01:44:00")
next_index=0

function handle_btn_press_2() {
	echo "Before: next_index = $next_index"
	if [[ "$1" =~ "${pattern[next_index]}" ]]; then
		echo "Progressing to next index"
		((next_index++))
	else
		next_index=0
	fi

	if [[ "$next_index" = "${#pattern[@]}" ]]; then
		echo "Pattern matching finished!"
		next_index=0
	fi

	echo "After: next_index = $next_index"
}

state=0
function handle_btn_press() {
	if [[ "$line" =~ "01:44:01" ]]; then # Up
		state=1
	elif [[ $state = 1 ]] && [[ "$line" =~ "01:44:02" ]]; then # Down
		state=2
	elif [[ $state = 2 ]] && [[ "$line" =~ "01:44:03" ]]; then # Left
		state=3
	elif [[ $state = 3 ]] && [[ "$line" =~ "01:44:04" ]]; then # Right
		state=4
	elif [[ $state = 4 ]] && [[ "$line" =~ "01:44:00" ]]; then # Enter/select
		echo "Pattern matched!"
		state=0
	else
		state=0
	fi

	echo "Recorded '$line'"
	echo "New state: $state"
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
        # TV directly requests recorder's vendor info.
        # This is our cue to discover if the TV is on.
        *01:8c*)
            request_tv_power_status
            ;;
        # TV directly reports power status.
        *10:90*)
            handle_tv_power_status "$line"
            ;;
	*01:44*)
	    handle_btn_press_2 "$line"
	    ;;
	*f:82*)
	    echo "$line"
	    if [[ "$line" =~ "1f:82" ]]; then
		    echo "Current device is active input"
	    else
		    echo "Another device is active input"
	    fi
	    ;;
    esac
done
