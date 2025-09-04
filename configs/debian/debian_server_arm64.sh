#!/bin/bash
set -euo pipefail

SUITE=trixie
ARCH=arm64
ROOTDIR=${1:-/tmp/rootfs}
KEYRING="/usr/share/keyrings/debian-archive-keyring.gpg"
MIRRORS=(http://ftp.cn.debian.org/debian http://ftp.de.debian.org/debian )

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

#echo "Packages to install: $(IFS=,; echo "${PACKAGES[*]}")"

echo "sources.list: ${MIRRORS[@]}"

# echo "$(IFS=,; echo "${PACKAGES[*]}")"

mmdebstrap \
  --arch=$ARCH \
  --aptopt='Acquire::Retries=5' \
  --aptopt='Acquire::http::Timeout=30' \
  --aptopt='Acquire::https::Timeout=30' \
  --aptopt='APT::Get::Assume-Yes=true' \
  --aptopt='DPkg::Options::=--force-confnew' \
  --aptopt='Acquire::Languages="none"' \
  --skip=download/bytecode \
  --variant=standard \
  --components=main,contrib \
  --keyring="$KEYRING" \
  --mode=auto \
  --include="$(IFS=,; echo "${PACKAGES[*]}")" \
  "$SUITE" \
  "$ROOTDIR" \
  "${MIRRORS[@]}"


[ -d "$ROOTDIR" ] || { echo "Rootfs directory $ROOTDIR not found"; exit 1; }

# ---- Host-side file copy ----
echo "[INFO] configure rootfs ..."

mkdir -p "$ROOTDIR"/usr/local/bin \
         "$ROOTDIR"/lib/systemd/system \
         "$ROOTDIR"/etc/udev/rules.d \
         "$ROOTDIR"/etc/modprobe.d \
         "$ROOTDIR"/etc/systemd/system/multi-user.target.wants \
         "$ROOTDIR"/etc/systemd/system/graphical.target.wants \
         "$ROOTDIR"/etc/systemd/system/local-fs.target.wants

install -D -m 644 src/system/boot.mount            "$ROOTDIR"/lib/systemd/system/boot.mount
install -D -m 755 tools/flex-installer             "$ROOTDIR"/usr/bin/flex-installer
install -D -m 755 tools/resizerfs                  "$ROOTDIR"/usr/bin/resizerfs
install -D -m 644 src/system/udev/udev-rules-*/*.rules "$ROOTDIR"/etc/udev/rules.d/
install -D -m 755 src/system/distroplatcfg         "$ROOTDIR"/usr/bin/distroplatcfg
install -D -m 644 src/system/platcfg.service       "$ROOTDIR"/lib/systemd/system/platcfg.service
install -D -m 644 src/system/blacklist.conf        "$ROOTDIR"/etc/modprobe.d/blacklist.conf
install -D -m 644 src/system/ts.conf               "$ROOTDIR"/etc/ts.conf.bak
install -D -m 755 src/system/board_id.sh           "$ROOTDIR"/usr/bin/board_id.sh
install -D -m 644 src/system/80-wired.network      "$ROOTDIR"/usr/lib/systemd/network/80-wired.network

# ---- Rootfs configuration inside chroot ----
#echo "[POST_ROOTFS] Configuring rootfs in chroot"

chroot "$ROOTDIR" /bin/bash -e <<'EOF'
# Create missing directories
mkdir -p /usr/local/bin \
         /etc/udev/rules.d \
         /etc/modprobe.d \
         /etc/systemd/system/multi-user.target.wants \
         /etc/systemd/system/graphical.target.wants \
         /etc/systemd/system/local-fs.target.wants

# User and group setup
id -u debian &>/dev/null || useradd -m -d /home/debian -s /bin/bash debian
getent group wayland &>/dev/null || groupadd wayland
usermod -aG sudo,input,video,wayland,render debian || true
passwd --delete root >/dev/null || true
passwd --delete debian >/dev/null || true

# SSH configuration
grep -q '^PermitRootLogin' /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
grep -q '^PermitEmptyPasswords' /etc/ssh/sshd_config || echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

# systemd service symlinks
ln -sf /lib/systemd/system/platcfg.service /etc/systemd/system/multi-user.target.wants/platcfg.service
ln -sf /lib/systemd/system/boot.mount /etc/systemd/system/local-fs.target.wants/boot.mount

# Symlinks and firmware
ln -sf /boot/tools/perf /usr/local/bin/perf
ln -sf /sbin/init /init
ln -sf /boot/modules /lib/modules
rm -rf /lib/firmware
ln -sf /boot/firmware /lib/firmware

# Locale setup
sed -i -e "s/.*en_US.UTF-8.*/en_US.UTF-8 UTF-8/" /etc/locale.gen
/usr/sbin/locale-gen >/dev/null 2>&1 || true
echo "localhost" > /etc/hostname
/usr/sbin/update-locale LANG=en_US.UTF-8 || true

# Root user bashrc
cat >> /etc/environment <<'EOT'
COGL_DRIVER=gles2
CLUTTER_DRIVER=gles2
QT_QPA_PLATFORM=wayland
GDK_GL=gles
QT_QUICK_BACKEND=software
EOT

grep -q 'WAYLAND_DISPLAY' /root/.bashrc || \
	printf "\nexport DISPLAY=:0\nexport WAYLAND_DISPLAY=wayland-0\n" >> /root/.bashrc

# Other system settings
printf "/usr/lib\n" >> /etc/ld.so.conf.d/01-sdk.conf
{
  echo " * Support:   https://www.nxp.com/support"
  echo " * Licensing: https://lsdk.github.io/eula"
} > /etc/update-motd.d/20-help-text
printf "Build: $(date --rfc-3339 seconds)\n" >> /etc/buildinfo
EOF

printf "%s %s (optimized with NXP-specific hardware acceleration)\n" \
  "${DISTRIB_NAME:-Debian}" "${DISTRIB_VERSION:-lsdk2512}" >> "$ROOTDIR"/etc/issue
# ---- Board-specific customization on host ----
# echo "[POST_ROOTFS] Board-specific configuration"

case "$MACHINE" in
    ls1028*)
		install -D -m 644 "$FBDIR"/src/system/weston/weston.ini.ls1028 \
			"$ROOTDIR"/etc/xdg/weston/weston.ini
        ;;
    imx*)
        mkdir -p "$ROOTDIR"/etc/xdg/weston
        cp -f "$FBDIR"/src/system/weston/weston.ini* "$ROOTDIR"/etc/xdg/weston/
        if [ -f "$ROOTDIR"/etc/pam.d/gdm-password ]; then
            install -D -m 644 "$FBDIR"/src/system/gdm/daemon.conf "$ROOTDIR"/etc/gdm3
            install -D -m 644 "$FBDIR"/src/system/gdm/gdm-password "$ROOTDIR"/etc/pam.d
            install -D -m 644 "$FBDIR"/src/system/gdm/gdm.service "$ROOTDIR"/lib/systemd/system/
            ln -sf /lib/systemd/system/gdm.service "$ROOTDIR"/etc/systemd/system/graphical.target.wants/gdm.service
        fi
        ;;
esac

#echo "[POST_ROOTFS] Finished"

