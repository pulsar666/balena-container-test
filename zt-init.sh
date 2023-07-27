#!/bin/bash
set -e

# Create the volume directory for ZeroTier One data
mkdir -p /var/lib/zerotier-one

# Expose the required ports for ZeroTier
iptables -A INPUT -p udp -m udp --dport 9993 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9993 -j ACCEPT

# Start the ZeroTier service
zerotier-one

# Join the ZeroTier network using the provided network ID
zerotier-cli join $ZT_NETWORK_ID

# Keep the container running
tail -f /dev/null