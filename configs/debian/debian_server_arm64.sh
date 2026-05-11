#!/bin/bash
set -euo pipefail

SUITE=trixie
ARCH=arm64
ROOTDIR=${1:-/tmp/rootfs}
KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"

DEBIAN_MIRRORS="${DEBIAN_MIRRORS:-http://deb.debian.org/debian}"
IFS=' ' read -r -a MIRRORS <<< "$DEBIAN_MIRRORS"

DEFAULT_PACKAGES=(
  init udev sudo vim apt file zstd parted fdisk dosfstools iputils-ping isc-dhcp-client
  wget curl ca-certificates systemd systemd-sysv psmisc ethtool iproute2 openssh-server
  openssh-client patchelf htop util-linux lshw keyutils wpasupplicant strongswan-starter
  tcpdump mtd-utils pciutils hdparm libssl-dev usbutils sysstat lsb-release kexec-tools iptables
  libhugetlbfs0 strongswan-charon dmidecode flex systemd-timesyncd initramfs-tools fbset
  mmc-utils i2c-tools lm-sensors rt-tests linuxptp mosquitto xterm bluez pipewire pipewire-audio
  pipewire-pulse wireplumber locales libspa-0.2-bluetooth net-tools
)

PACKAGES=("${DEFAULT_PACKAGES[@]}")
if [ $# -gt 1 ]; then
  EXTRA_PACKAGES=("${@:2}")
  PACKAGES+=("${EXTRA_PACKAGES[@]}")
fi
PACKAGES=($(printf '%s\n' "${PACKAGES[@]}" | awk '!seen[$0]++'))

#echo "Packages to install: $(IFS=,; echo "${PACKAGES[*]}")"

echo "sources.list: ${MIRRORS[@]}"

# echo "$(IFS=,; echo "${PACKAGES[*]}")"

mmdebstrap \
  --arch=$ARCH \
  --aptopt='Acquire::Retries=5' \
  --aptopt='Acquire::Queue-Mode=access' \
  --aptopt='Acquire::http::Pipeline-Depth=200' \
  --aptopt='Acquire::http::Timeout=30' \
  --aptopt='Acquire::https::Timeout=30' \
  --aptopt='Acquire::Languages="none"' \
  --aptopt='APT::Get::Assume-Yes=true' \
  --aptopt='APT::Acquire::Retries=5' \
  --aptopt='DPkg::Options::=--force-confnew' \
  --aptopt='DPkg::Options::=--force-unsafe-io' \
  --aptopt='Dpkg::Progress-Fancy=1' \
  --skip=download/bytecode \
  --variant=standard \
  --components=main,contrib \
  --keyring="$KEYRING" \
  --mode=auto \
  --include="$(IFS=,; echo "${PACKAGES[*]}")" \
  "$SUITE" \
  "$ROOTDIR" \
  "${MIRRORS[@]}"

