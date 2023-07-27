#!/bin/bash
set -e

# Create the volume directory for ZeroTier One data
mkdir -p /var/lib/zerotier-one

# Expose the required ports for ZeroTier
iptables -A INPUT -p udp -m udp --dport 9993 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9993 -j ACCEPT

# Start the ZeroTier service and redirect the output to a log file
zerotier-one -D > /var/log/zt-join.log 2>&1 &

# Wait for the ZeroTier service to start
sleep 5

# Join the ZeroTier network using the provided network ID and redirect the output to the log file
zerotier-cli join $ZT_NETWORK_ID >> /var/log/zt-init.log 2>&1

# Keep the container running
tail -f /dev/null