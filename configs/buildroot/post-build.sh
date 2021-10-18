#!/bin/bash
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#


set -e
DESTDIR=$FBOUTDIR/apps/components_${DESTARCH}_buildroot
cp $FBDIR/tools/flex-installer ${TARGET_DIR}/usr/bin
cp $FBDIR/configs/buildroot/ps1.sh ${TARGET_DIR}/etc/profile.d
mkdir -p ${TARGET_DIR}/usr/{include,local}

if [ $DESTARCH = arm64 ]; then
    if [ ! -f $DESTDIR/etc/buildinfo ]; then
	bld -c apps -r buildroot:${DISTROSCALE} -f $CONFIGLIST && \
	releasestamp="Built at: `date +'%Y-%m-%d %H:%M:%S'`" && \
	echo $releasestamp > $DESTDIR/etc/buildinfo
    fi
    echo merge apps components from $DESTDIR to ${TARGET_DIR} ...
    cp -rf $DESTDIR/* ${TARGET_DIR}/
fi

# setup kernel lib modules
curbrch=`cd $KERNEL_PATH && git branch | grep ^* | cut -d' ' -f2 && cd $FBDIR`
libmodules=$FBOUTDIR/linux/kernel/$DESTARCH/$SOCFAMILY/output/$curbrch/tmp/lib/modules
modulename=$(echo `ls -t $libmodules` | cut -d' ' -f1)
modulespath=$libmodules/$modulename
if [ -n "$modulename" -a $DISTROSCALE = devel ]; then
    rm -rf ${TARGET_DIR}/lib/modules/*
    cp -rf $modulespath ${TARGET_DIR}/lib/modules
fi

if [ -d ${TARGET_DIR}/etc/udev/rules.d ]; then
    sudo cp -f $FBDIR/src/misc/udev/udev-rules-qoriq/72-fsl-dpaa-persistent-networking.rules ${TARGET_DIR}/etc/udev/rules.d
    sudo cp -f $FBDIR/src/misc/udev/udev-rules-qoriq/73-fsl-enetc-networking.rules ${TARGET_DIR}/etc/udev/rules.d
fi
