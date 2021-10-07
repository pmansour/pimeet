#!/bin/bash

if [[ "`id -u`" -ne 0 ]]; then
    echo "This script must be run as root. Try running 'sudo $1'."
    exit 1
fi

DOWNLOAD_URL='https://github.com/pmansour/minimeet/releases/download/stable/mv3.zip'
TMP_ZIP_FILE=`mktemp`
EXTENSION_SRC_DIR='/usr/local/minimeet'

# Backup credentials file.
echo "Backing up credentials file.."
CREDS_BACKUP_FILE=`mktemp`
cp "$EXTENSION_SRC_DIR/config/creds.js" "$CREDS_BACKUP_FILE"

# Download and unzip new extension
echo "Downloading latest extension.."
wget -q --show-progress "$DOWNLOAD_URL" -O "$TMP_ZIP_FILE"
echo "Deleting old extension.."
rm -rf "$EXTENSION_SRC_DIR"
echo "Extracting archive to '$EXTENSION_SRC_DIR'.."
mkdir -p "$EXTENSION_SRC_DIR"
unzip -d "$EXTENSION_SRC_DIR" "$TMP_ZIP_FILE"
rm "$TMP_ZIP_FILE"

echo "Restoring credentials file.."
mkdir -p "$EXTENSION_SRC_DIR/config"
cp "$CREDS_BACKUP_FILE" "$EXTENSION_SRC_DIR/config/creds.js"

echo "Updating permissions.."
chmod -R a+rwx /usr/local/minimeet

echo "Done."

