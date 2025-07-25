#!/bin/bash
set -e

SUITE=trixie
ARCH=arm64
TARGET_DIR=${1:-/tmp/rootfs}
MIRRORS=(http://ftp.cn.debian.org/debian http://ftp.de.debian.org/debian http://deb.debian.org/debian)

PACKAGES=(
  init udev sudo vim apt file zstd parted fdisk dosfstools iputils-ping isc-dhcp-client
  wget curl ca-certificates systemd systemd-sysv psmisc ethtool iproute2 openssh-server
  openssh-client patchelf htop util-linux lshw keyutils locales wpasupplicant net-tools
)

echo "Running mmdebstrap with mirrors: ${MIRRORS[@]}"

mmdebstrap \
  --arch=$ARCH \
  --variant=minbase \
  --include="$(IFS=,; echo "${PACKAGES[*]}")" \
  --keyring=/usr/share/keyrings/debian-archive-keyring.gpg \
  --mode=unshare \
  --setup-hook='
    mkdir -p "$1"/usr/local/bin "$1"/etc/udev/rules.d "$1"/etc/modprobe.d
    mkdir -p "$1"/etc/systemd/system/multi-user.target.wants
    mkdir -p "$1"/etc/systemd/system/graphical.target.wants
    mkdir -p "$1"/etc/systemd/system/local-fs.target.wants
  ' \
  --essential-hook='sleep 1' \
  --customize-hook='
    chroot "$1" useradd -m -d /home/debian -s /bin/bash debian
    chroot "$1" groupadd wayland
    chroot "$1" usermod -aG sudo,input,video,wayland,render debian
    chroot "$1" passwd --delete root
    chroot "$1" passwd --delete debian
    chroot "$1" apt-get update
    chroot "$1" cp /etc/skel/.bashrc /home/debian/.bashrc
    echo "PermitRootLogin yes" >> "$1"/etc/ssh/sshd_config
    echo "PermitEmptyPasswords yes" >> "$1"/etc/ssh/sshd_config
    cp src/system/boot.mount "$1"/lib/systemd/system/
    cp tools/flex-installer "$1"/usr/bin/
    cp tools/resizerfs "$1"/usr/bin/
    cp src/system/udev/udev-rules-*/*.rules "$1"/etc/udev/rules.d/
    cp src/system/blacklist.conf "$1"/etc/modprobe.d/
    cp src/system/ts.conf "$1"/etc/ts.conf.bak
    cp src/system/board_id.sh "$1"/usr/bin/
    cp src/system/debian-post-install-pkg "$1"/usr/bin/
    cp src/system/80-wired.network "$1"/usr/lib/systemd/network/
    cp configs/debian/extra_packages_list "$1"/etc/
    chroot "$1" ln -s /lib/systemd/system/boot.mount /etc/systemd/system/local-fs.target.wants/boot.mount
    chroot "$1" ln -s /boot/tools/perf /usr/local/bin/perf
    chroot "$1" ln -s /sbin/init /init
    chroot "$1" ln -s /boot/modules /lib/modules
    chroot "$1" rm -rf /lib/firmware
    chroot "$1" ln -s /boot/firmware /lib/firmware
    chroot "$1" sed -i -e "s/.*zh_CN.UTF-8.*/zh_CN.UTF-8 UTF-8/" -e "s/.*en_US.UTF-8.*/en_US.UTF-8 UTF-8/" /etc/locale.gen
    chroot "$1" /usr/sbin/locale-gen
    chroot "$1" echo "localhost" > "$1/etc/hostname"
    chroot "$1" /usr/sbin/update-locale LANG=en_US.UTF-8
    printf "COGL_DRIVER=gles2\nCLUTTER_DRIVER=gles2\nQT_QPA_PLATFORM=wayland\nGDK_GL=gles\n" >> "$1"/etc/environment
    printf "QT_QUICK_BACKEND=software\n" >> "$1"/etc/environment
    printf "\nexport DISPLAY=:0\nexport WAYLAND_DISPLAY=wayland-0" >> "$1"/root/.bashrc
    printf "/usr/lib\n" >> "$1"/etc/ld.so.conf.d/01-sdk.conf
    printf " * Support:   https://www.nxp.com/support\n" >> "$1"/etc/update-motd.d/20-help-text
    printf " * Licensing: https://lsdk.github.io/eula\n" >> "$1"/etc/update-motd.d/20-help-text
    printf "NXP Linux SDK 2512 Debian Distro (optimized with NXP-specific hardware acceleration)\n" >> "$1"/etc/issue
    printf "Build: $(date --rfc-3339 seconds)\n" >> "$1"/etc/buildinfo
  ' \
  "$SUITE" \
  "$TARGET_DIR" \
  "${MIRRORS[@]}"
