#!/bin/bash

# Define variables
HOST_FILE=/etc/hosts
TMP_HOST_FILE=/tmp/etc-hosts
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=/tmp/etc-hosts-$TIMESTAMP.out

# Redirect output to log file
exec > $LOG_FILE 2>&1

# Fetch the latest hosts file from GitHub
wget -q https://raw.githubusercontent.com/natarajaninbox/imac-etc-hosts-control/main/etc-hosts -O $TMP_HOST_FILE || exit 1

# Get the checksum of the current file
checksum=$(md5 -q $HOST_FILE)

# Get the checksum of the file on GitHub
github_checksum=$(md5 -q $TMP_HOST_FILE)

echo "Local checksum: $checksum"
echo "GitHub checksum: $github_checksum"

# If the checksums don't match, update the file
if [[ "$checksum" != "$github_checksum" ]]; then
  echo "Updating local /etc/hosts file"
  cp $HOST_FILE $HOST_FILE.$TIMESTAMP.bak  
  mv $TMP_HOST_FILE $HOST_FILE
  # Flush DNS cache
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  echo "DNS cache flushed"
else
  echo "No changes detected"
fi
