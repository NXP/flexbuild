#!/bin/bash
set -euo pipefail
ROOTDIR=${1:-/tmp/rootfs}

[ -d "$ROOTDIR" ] || { echo "Rootfs directory $ROOTDIR not found"; exit 1; }

# ---- Host-side file copy ----
echo -e "\n[INFO] setting up rootfs "

mkdir -p "$ROOTDIR"/usr/local/bin \
         "$ROOTDIR"/lib/systemd/system \
         "$ROOTDIR"/etc/udev/rules.d \
         "$ROOTDIR"/etc/modprobe.d \
         "$ROOTDIR"/etc/systemd/system/multi-user.target.wants \
         "$ROOTDIR"/etc/systemd/system/graphical.target.wants \
         "$ROOTDIR"/etc/systemd/system/local-fs.target.wants \
         "$ROOTDIR"/usr/share/wireplumber/wireplumber.conf.d

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
install -D -m 755 src/system/debian-post-install-pkg "$ROOTDIR"/usr/bin/
install -D -m 644 src/system/51-bluez-imx.conf       "$ROOTDIR"/usr/share/wireplumber/wireplumber.conf.d/
install -D -m 644 src/system/80-disable-logind.conf  "$ROOTDIR"/usr/share/wireplumber/wireplumber.conf.d/
install -D -m 644 configs/debian/extra_packages_list "$ROOTDIR"/etc/


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
# ln -sf /lib/systemd/system/platcfg.service /etc/systemd/system/multi-user.target.wants/platcfg.service
ln -sf /lib/systemd/system/boot.mount /etc/systemd/system/local-fs.target.wants/boot.mount

# Symlinks and firmware
ln -sf /boot/tools/perf /usr/local/bin/perf
ln -sf /sbin/init /init
ln -sf /boot/modules /lib/modules
# rm -rf /lib/firmware
# ln -sf /boot/firmware /lib/firmware

# fix absolute path for libz.so symlink when cross compiling apitrace
ln -sf libz.so.1 /usr/lib/aarch64-linux-gnu/libz.so

# fixup for libtinfo.so needed by tsntool
ln -sf libtinfo.so.6 /usr/lib/aarch64-linux-gnu/libtinfo.so

# fixup for Qt6 app cross-compiling
ln -sf libQt6Quick.so.6 /usr/lib/aarch64-linux-gnu/libQt6Quick.so
ln -sf libQt6OpenGL.so.6 /usr/lib/aarch64-linux-gnu/libQt6OpenGL.so
ln -sf libQt6QmlModels.so.6 /usr/lib/aarch64-linux-gnu/libQt6QmlModels.so
ln -sf libQt6Qml.so.6 /usr/lib/aarch64-linux-gnu/libQt6Qml.so

# fix ping: socket: Operation not permitted
chmod u+s /bin/ping

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

mkdir -p "$ROOTDIR"/etc/xdg/weston
cp -f "$FBDIR"/src/system/weston/weston.ini* "$ROOTDIR"/etc/xdg/weston/

#echo "[POST_ROOTFS] Finished"

