#!/bin/bash
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#

set -e

IMGDIR=$FBOUTDIR/images
mkdir -p $IMGDIR
rfsname=rootfs_${DISTRIB_VERSION}_buildroot_${DISTROSCALE}_${DESTARCH}
cp -f ${BINARIES_DIR}/rootfs.cpio.gz $IMGDIR/${rfsname}.cpio.gz
cp -f ${BINARIES_DIR}/rootfs.ext2.gz $IMGDIR/${rfsname}.ext2.gz
cp -f ${BINARIES_DIR}/rootfs.jffs2 $IMGDIR/${rfsname}.jffs2
cp -f ${BINARIES_DIR}/rootfs.squashfs $IMGDIR/${rfsname}.squashfs
