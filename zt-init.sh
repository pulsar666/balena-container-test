#!/bin/bash

printf "### Starting ZeroTier interface"

service zerotier-one start
sleep 5
zerotier-cli join $ZT_NETWORK_ID
zerotier-cli set $ZT_NETWORK_ID allowManaged=0

# Keep the container running
tail -f /dev/null