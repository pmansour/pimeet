#!/bin/bash
# Resets the configuration profile on this device, without requiring a full re-image.
# Prerequisites: mkpasswd (part of whois), tree.
# Usage:
#   Interactive mode: ./reset-profile.sh
#   Config mode: ./reset-profile.sh CONFIG_FILE

# Exit if any command fails.
set -e

if [[ "`id -u`" -ne 0 ]]; then
    echo "This script must be run as root. Try running 'sudo $1'." >&2
    exit 1
fi

# $1 is context, $2 is value.
function debug {
    if [[ ! "$1" = "" ]]; then
        echo -e "\e[3m> $1:\n\e[0m" >&2
    fi
    echo -e "\e[3m$2\e[0m" >&2
}

if [ -z "$2" ]; then
    # Interactive mode

    read -p "Enter new password for 'pi' user: " PI_PASSWORD
    HASHED_PI_PASSWORD=`mkpasswd -5 "$PI_PASSWORD"`
    PI_PASSWORD='' # Empty sensitive variables

    # TODO: should we do WiFi here too? Consider adding a loop to add n networks.
    # Consider using wpasupplicant if it's installed.

    read -p "New hostname: " -r HOSTNAME

    read -p "Enter Google email address: " GOOGLE_ACCOUNT_EMAIL
    read -p "Enter Google password: " GOOGLE_ACCOUNT_PASSWORD
else
    # Config mode -- first argument should be the config file.
    source "$2"

    if [ -z "$HASHED_PI_PASSWORD" ] || [ -z "$HOSTNAME" ] || [ -z "$GOOGLE_ACCOUNT_EMAIL" ] || [ -z "$GOOGLE_ACCOUNT_PASSWORD" ]; then
        echo "One or more configs are missing from the config file. Please ensure that the following variables are set: HASHED_PI_PASSWORD, HOSTNAME, GOOGLE_ACCOUNT_EMAIL, GOOGLE_ACCOUNT_PASSWORD." >&2
        exit 1
    fi
fi

# Update the 'pi' user's password.
# Use @ as sed's delimiter since the hashed password may include slashes.
sed -E -i "s@^pi:[^:]*:@pi:${HASHED_PI_PASSWORD}:@" "/etc/shadow"
debug 'Hashed password' "`cat "/etc/shadow" | grep -E "^pi:"`"

# Update the hostname.
echo "$HOSTNAME" | sudo tee "/etc/hostname"
sudo sed -i "s/127.0.1.1.*$/127.0.1.1\t$HOSTNAME/g" "/etc/hosts"
debug '/etc/hostname' "`cat "/etc/hostname"`"
debug '/etc/hosts' "`cat "/etc/hosts"`"

# Update Google account creds.
sudo mkdir -p "/usr/local/minimeet/config"
cat <<EOF | sudo tee "/usr/local/minimeet/config/creds.js" >/dev/null
export const EMAIL_ADDRESS = '$GOOGLE_ACCOUNT_EMAIL';
export const PASSWORD = '$GOOGLE_ACCOUNT_PASSWORD';
EOF
debug 'config/creds.js' "`cat "/usr/local/minimeet/config/creds.js"`"
debug 'Minimeet extension directory' "`tree "/usr/local/minimeet"`"
