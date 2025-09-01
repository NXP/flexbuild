#!/bin/bash
set -e

ROOTDIR="$1"
[ -d "$ROOTDIR" ] || { echo "Rootfs directory $ROOTDIR not found"; exit 1; }

# ---- Host-side file copy ----
# echo "[POST_ROOTFS] Copying files into $ROOTDIR"

mkdir -p "$ROOTDIR"/usr/local/bin \
         "$ROOTDIR"/lib/systemd/system \
         "$ROOTDIR"/etc/udev/rules.d \
         "$ROOTDIR"/etc/modprobe.d \
         "$ROOTDIR"/etc/systemd/system/multi-user.target.wants \
         "$ROOTDIR"/etc/systemd/system/graphical.target.wants \
         "$ROOTDIR"/etc/systemd/system/local-fs.target.wants

cp -f src/system/boot.mount            "$ROOTDIR"/lib/systemd/system/
cp -f tools/flex-installer            "$ROOTDIR"/usr/bin/
cp -f tools/resizerfs                  "$ROOTDIR"/usr/bin/
cp -f src/system/udev/udev-rules-*/*.rules "$ROOTDIR"/etc/udev/rules.d/
cp -f src/system/distroplatcfg         "$ROOTDIR"/usr/bin/
cp -f src/system/platcfg.service       "$ROOTDIR"/lib/systemd/system/
cp -f src/system/blacklist.conf        "$ROOTDIR"/etc/modprobe.d/
cp -f src/system/ts.conf               "$ROOTDIR"/etc/ts.conf.bak
cp -f src/system/board_id.sh           "$ROOTDIR"/usr/bin/
cp -f src/system/80-wired.network      "$ROOTDIR"/usr/lib/systemd/network/

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
useradd -m -d /home/debian -s /bin/bash debian || true
groupadd wayland || true
usermod -aG sudo,input,video,wayland,render debian || true
passwd --delete root || true
passwd --delete debian || true

# SSH configuration
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PermitEmptyPasswords yes" >> /etc/ssh/sshd_config

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
/usr/sbin/locale-gen
echo "localhost" > /etc/hostname
/usr/sbin/update-locale LANG=en_US.UTF-8

# Root user bashrc
printf "COGL_DRIVER=gles2\nCLUTTER_DRIVER=gles2\nQT_QPA_PLATFORM=wayland\nGDK_GL=gles\n" >> /etc/environment
printf "QT_QUICK_BACKEND=software\n" >> /etc/environment
printf "\nexport DISPLAY=:0\nexport WAYLAND_DISPLAY=wayland-0" >> /root/.bashrc

# Other system settings
printf "/usr/lib\n" >> /etc/ld.so.conf.d/01-sdk.conf
printf " * Support:   https://www.nxp.com/support\n" >> /etc/update-motd.d/20-help-text
printf " * Licensing: https://lsdk.github.io/eula\n" >> /etc/update-motd.d/20-help-text
printf "NXP Linux SDK 2512 Debian Distro (optimized with NXP-specific hardware acceleration)\n" >> /etc/issue
printf "Build: $(date --rfc-3339 seconds)\n" >> /etc/buildinfo
EOF

# ---- Board-specific customization on host ----
# echo "[POST_ROOTFS] Board-specific configuration"

if [ "$DISTROVARIANT" != "base" ]; then
    case "$MACHINE" in
        ls1028*)
            mkdir -p "$ROOTDIR"/etc/xdg/weston
            cp -f "$FBDIR"/src/system/weston/weston.ini.ls1028 "$ROOTDIR"/etc/xdg/weston/
            ;;
        imx*)
            mkdir -p "$ROOTDIR"/etc/xdg/weston
            cp -f "$FBDIR"/src/system/weston/weston.ini* "$ROOTDIR"/etc/xdg/weston/
            if [ -f "$ROOTDIR"/etc/pam.d/gdm-password ]; then
                cp -f "$FBDIR"/src/system/gdm/daemon.conf "$ROOTDIR"/etc/gdm3
                cp -f "$FBDIR"/src/system/gdm/gdm-password "$ROOTDIR"/etc/pam.d
                cp -f "$FBDIR"/src/system/gdm/gdm.service "$ROOTDIR"/lib/systemd/system/
                ln -sf /lib/systemd/system/gdm.service "$ROOTDIR"/etc/systemd/system/graphical.target.wants/gdm.service
            fi
            ;;
    esac
fi

#echo "[POST_ROOTFS] Finished"

