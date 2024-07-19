#!/bin/bash

# Define variables
HOST_FILE=/etc/hosts
TMP_HOST_FILE=/tmp/etc-hosts
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=/tmp/etc-hosts-$TIMESTAMP.out

# Remove previous log files
rm -f /tmp/etc-hosts-*.out

# Redirect output to log file
exec > $LOG_FILE 2>&1

# Fetch the latest hosts file from GitHub
echo "Downloading latest hosts file from GitHub..."
curl -s -o $TMP_HOST_FILE https://raw.githubusercontent.com/natarajaninbox/imac-etc-hosts-control/main/etc-hosts || { echo "Failed to download file"; exit 1; }

# Check if the file was downloaded successfully
if [[ ! -f $TMP_HOST_FILE ]]; then
  echo "Download failed. File does not exist."
  exit 1
fi

# Get the checksum of the current file
checksum=$(md5 -q $HOST_FILE)

# Get the checksum of the file on GitHub
github_checksum=$(md5 -q $TMP_HOST_FILE)

echo "Local checksum: $checksum"
echo "GitHub checksum: $github_checksum"

# If the checksums don't match, update the file
if [[ "$checksum" != "$github_checksum" ]]; then
  echo "Updating local /etc/hosts file..."
  cp $HOST_FILE $HOST_FILE.$TIMESTAMP.bak
  mv $TMP_HOST_FILE $HOST_FILE

  # Flush DNS cache
  echo "Flushing DNS cache..."
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  sudo killall -HUP mDNSResponderHelper
  
  echo "DNS cache flushed and mDNSResponder services restarted."

else
  echo "No changes detected. The files are identical."
fi
