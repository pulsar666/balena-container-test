# Use the official ZeroTier Docker image
FROM zerotier/zerotier-containerized

# Expose the ZeroTier port
EXPOSE 9993/udp

# Set the network ID and API key as build arguments
ARG ZT_NETWORK_ID
ARG ZT_API_KEY

# Set the network ID and API key as environment variables
ENV ZT_NETWORK_ID=${ZT_NETWORK_ID}
ENV ZT_API_KEY=${ZT_API_KEY}

# Start the ZeroTier service
CMD ["zerotier-one"]
