#!/bin/bash

# Flush DNS cache
sudo dscacheutil -flushcache
echo "DNS cache flushed"

sudo killall -HUP mDNSResponder
echo "Killed mDNSResponder"

sudo killall -HUP mDNSResponderHelper
echo "Killed mDNSResponderHelper"
