#!/bin/bash
set -e

SUITE=trixie
ARCH=arm64
TARGET_DIR=${1:-/tmp/rootfs}
MIRRORS=(http://deb.debian.org/debian)

PACKAGES=(
  init udev sudo vim apt file zstd parted fdisk dosfstools iputils-ping isc-dhcp-client
  wget curl ca-certificates systemd systemd-sysv psmisc ethtool iproute2 openssh-server
  openssh-client patchelf htop util-linux lshw keyutils locales wpasupplicant net-tools
)

# echo "Running mmdebstrap with mirrors: ${MIRRORS[@]}"

mmdebstrap \
  --arch=$ARCH \
  --variant=minbase \
  --include="$(IFS=,; echo "${PACKAGES[*]}")" \
  --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
  --mode=unshare \
  "$SUITE" \
  "$TARGET_DIR" \
  "${MIRRORS[@]}"
