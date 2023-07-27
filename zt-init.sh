#!/bin/bash
set -e

# Start the ZeroTier service and redirect the output to a log file
zerotier-one -D > /var/log/zt-join.log 2>&1 &

# Wait for the ZeroTier service to start
sleep 5

# Join the ZeroTier network using the provided network ID and redirect the output to the log file
zerotier-cli join $ZT_NETWORK_ID >> /var/log/zt-init.log 2>&1

# Keep the container running
tail -f /dev/null