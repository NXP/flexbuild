#!/bin/bash
#
# Copyright 2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


if [ $1 = fixcfg ]; then
    # reconfigure busybox in poky
    sed -i 's/# CONFIG_DEVMEM is not set/CONFIG_DEVMEM=y/' $PKGDIR/yocto/poky/meta/recipes-core/busybox/busybox/defconfig
    sed -i 's/# CONFIG_TC is not set/CONFIG_TC=y/' $PKGDIR/yocto/poky/meta/recipes-core/busybox/busybox/defconfig
    
    # add poky custom packages with recipes
    # sudo cp -rf $FBDIR/src/misc/poky/recipes-support/* $PKGDIR/yocto/poky/meta/recipes-support/

    # reconfigure machine serial console
    [ $DESTARCH = arm64 ] && cfgfile=qemuarm64.conf || cfgfile=qemuarm.conf
    sed -i -e 's/ttyAMA0/ttyS0/' -e 's/hvc0//' $PKGDIR/yocto/poky/meta/conf/machine/$cfgfile
fi

if [ $1 = fixlib ]; then
    # fixup lib absolute path in $RFSDIR/usr/lib/libc.so for building some app components
    sudo sed -i 's|GROUP ( /lib/libc.so.6 /usr/lib/libc_nonshared.a  AS_NEEDED ( /lib/ld-linux-aarch64.so.1 ) )|GROUP ( ../../lib/libc.so.6 ./libc_nonshared.a  AS_NEEDED    ( ../../lib/ld-linux-aarch64.so.1 ) )|' $2
    sudo sed -i 's|GROUP ( /lib/libc.so.6 /usr/lib/libc_nonshared.a  AS_NEEDED ( /lib/ld-linux-armhf.so.3 ) )|GROUP ( ../../lib/libc.so.6 ./libc_nonshared.a  AS_NEEDED ( ../../lib/ld-linux-armhf.so.3 ) )|' $2
fi

if [ $1 = fixsys ]; then
    RFSDIR=$2
    if ! grep -q LD_LIBRARY_PATH $RFSDIR/etc/profile; then
	echo export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/lib | sudo tee -a $RFSDIR/etc/profile 1>/dev/null
    fi
    sudo ln -sf /sbin/init $RFSDIR/init
    sudo mkdir -p $RFSDIR/etc/rpm-postinsts && sudo cp -f $FBDIR/src/misc/poky/100-sysvinit-inittab $RFSDIR/etc/rpm-postinsts
    sudo sed -i '/start_getty 115200  vt102/d' $RFSDIR/etc/inittab && sudo sed -i '/38400 tty1/d' $RFSDIR/etc/inittab
    cd $RFSDIR/etc/rcS.d && sudo ln -sf ../init.d/run-postinsts S99run-postinsts && cd - && \
    if ! grep -q ^S1 $RFSDIR/etc/inittab; then \
        sudo sed -i '/S0/a\S1:12345:respawn:/bin/start_getty 115200 ttyS1 vt102' $RFSDIR/etc/inittab
        sudo sed -i '/S1/a\AMA0:12345:respawn:/bin/start_getty 115200 ttyAMA0 vt102' $RFSDIR/etc/inittab
        sudo sed -i '/AMA0/a\mxc0:12345:respawn:/bin/start_getty 115200 ttymxc0 vt102' $RFSDIR/etc/inittab
        sudo sed -i '/mxc0/a\mxc1:12345:respawn:/bin/start_getty 115200 ttymxc1 vt102' $RFSDIR/etc/inittab
        sudo sed -i '/mxc1/a\LP0:12345:respawn:/bin/start_getty 115200 ttyLP0 vt102' $RFSDIR/etc/inittab
    fi
    if [ -d $RFSDIR/etc/udev/rules.d ]; then
	sudo cp -f $FBDIR/src/misc/udev/udev-rules-qoriq/72-fsl-dpaa-persistent-networking.rules $RFSDIR/etc/udev/rules.d
	sudo cp -f $FBDIR/src/misc/udev/udev-rules-qoriq/73-fsl-enetc-networking.rules $RFSDIR/etc/udev/rules.d
    fi
    sudo rm -f $RFSDIR/etc/rc5.d/S20distcc
fi
