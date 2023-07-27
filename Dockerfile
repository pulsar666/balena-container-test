FROM balenalib/aarch64-debian:bullseye-run
LABEL io.balena.device-type="raspberrypi4-64"
RUN echo "deb http://archive.raspberrypi.org/debian bullseye main ui" >>  /etc/apt/sources.list.d/raspi.list \
	&& apt-key adv --batch --keyserver keyserver.ubuntu.com  --recv-key 0x82B129927FA3303E

RUN apt-get update && apt-get install -y --no-install-recommends \
		less \
		libraspberrypi-bin \
		kmod \
		nano \
		net-tools \
		ifupdown \
		iputils-ping \
		i2c-tools \
		usbutils \
	&& rm -rf /var/lib/apt/lists/*

RUN [ ! -d /.balena/messages ] && mkdir -p /.balena/messages; echo 'Here are a few details about this Docker image (For more information please visit https://www.balena.io/docs/reference/base-images/base-images/): \nArchitecture: ARM v8 \nOS: Debian Bullseye \nVariant: run variant \nDefault variable(s): UDEV=off \nExtra features: \n- Easy way to install packages with `install_packages <package-name>` command \n- Run anywhere with cross-build feature  (for ARM only) \n- Keep the container idling with `balena-idle` command \n- Show base image details with `balena-info` command' > /.balena/messages/image-info

# Install ZeroTier One
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install required packages for ZeroTier One installation
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    apt-utils \
    && rm -rf /var/lib/apt/lists/*

# Add the GPG key for ZeroTier One
RUN curl https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg | gpg --dearmor | tee /usr/share/keyrings/zerotierone-archive-keyring.gpg >/dev/null

# Set the codename for the current operating system
RUN echo "deb [signed-by=/usr/share/keyrings/zerotierone-archive-keyring.gpg] http://download.zerotier.com/debian/$(cat /etc/os-release | grep -oP 'VERSION_CODENAME=\K\w+' | tr '[:upper:]' '[:lower:]') $(cat /etc/os-release | grep -oP 'VERSION_CODENAME=\K\w+' | tr '[:upper:]' '[:lower:]') main" | tee /etc/apt/sources.list.d/zerotier.list

# Update the package list and install ZeroTier One
RUN apt-get update && apt-get install -y --no-install-recommends \
    zerotier-one \
    && rm -rf /var/lib/apt/lists/*

# Set the network ID as a build argument (can be passed during the build)
ARG ZT_NETWORK_ID
ENV ZT_NETWORK_ID=${ZT_NETWORK_ID}
	
# Copy the zt-init.sh script into the container
COPY zt-init.sh /usr/src/app/zt-init.sh

# Set the script as executable
RUN chmod +x /usr/src/app/zt-init.sh

# Join the ZeroTier network using the provided network ID at runtime
CMD ["sh", "-c", "zerotier-one && zerotier-cli join $ZT_NETWORK_ID"]

