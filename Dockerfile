# Use the ARM64 (aarch64) Debian Bullseye base image
FROM arm64v8/debian:bullseye-slim
LABEL io.balena.architecture="aarch64"

# Install required packages and set up the environment
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    findutils \
    gnupg \
    dirmngr \
    inetutils-ping \
    netbase \
    curl \
    udev \
    procps \
    $(if apt-cache show 'iproute' 2>/dev/null | grep -q '^Version:'; then echo 'iproute'; else echo 'iproute2'; fi) \
    && rm -rf /var/lib/apt/lists/* \
    && c_rehash \
    && echo '#!/bin/sh\n\
set -e\n\
set -u\n\
export DEBIAN_FRONTEND=noninteractive\n\
n=0\n\
max=2\n\
until [ $n -gt $max ]; do\n\
  set +e\n\
  (\n\
    apt-get update -qq &&\n\
    apt-get install -y --no-install-recommends "$@"\n\
  )\n\
  CODE=$?\n\
  set -e\n\
  if [ $CODE -eq 0 ]; then\n\
    break\n\
  fi\n\
  if [ $n -eq $max ]; then\n\
    exit $CODE\n\
  fi\n\
  echo "apt failed, retrying"\n\
  n=$(($n + 1))\n\
done\n\
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*' > /usr/sbin/install_packages \
    && chmod 0755 "/usr/sbin/install_packages"

ENV LC_ALL C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV UDEV off

# 01_nodoc
RUN echo 'path-exclude /usr/share/doc/*\n\
# we need to keep copyright files for legal reasons\n\
path-include /usr/share/doc/*/copyright\n\
path-exclude /usr/share/man/*\n\
path-exclude /usr/share/groff/*\n\
path-exclude /usr/share/info/*\n\
path-exclude /usr/share/lintian/*\n\
path-exclude /usr/share/linda/*\n\
path-exclude /usr/share/locale/*\n\
path-include /usr/share/locale/en*' > /etc/dpkg/dpkg.cfg.d/01_nodoc

# 01_buildconfig
RUN echo 'APT::Get::Assume-Yes "true";\n\
APT::Install-Recommends "0";\n\
APT::Install-Suggests "0";\n\
quiet "true";' > /etc/apt/apt.conf.d/01_buildconfig

RUN mkdir -p /usr/share/man/man1

COPY entry.sh /usr/bin/entry.sh
COPY balena-info /usr/bin/balena-info
COPY balena-idle /usr/bin/balena-idle
ENTRYPOINT ["/usr/bin/entry.sh"]

# Install ZeroTier One
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -SLO "https://github.com/zerotier/ZeroTierOne/releases/download/1.8.4/zerotier-one_1.8.4_arm64.deb" \
    && dpkg -i zerotier-one_1.8.4_arm64.deb \
    && rm zerotier-one_1.8.4_arm64.deb

# Expose the ports required by ZeroTier
EXPOSE 9993/udp
EXPOSE 9993/tcp

# Set the network ID as a build argument (can be passed during the build)
ARG ZT_NETWORK_ID
ENV ZT_NETWORK_ID=${ZT_NETWORK_ID}

# Join the ZeroTier network using the provided network ID during the build
RUN zerotier-cli join ${ZT_NETWORK_ID}

# Start the ZeroTier service
CMD ["zerotier-one"]
