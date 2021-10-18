#!/bin/sh
#
# Copyright 2018 NXP
#
# SPDX-License-Identifier:      BSD-3-Clause
#



# mount the /proc and /sys filesystems.
/bin/mount -t proc none /proc
/bin/mount -t sysfs none /sys

a=`/bin/cat /proc/cmdline`

/bin/mount -n -t securityfs securityfs /sys/kernel/security

# Mount the root filesystem.
if ! echo $a | /bin/grep -q 'mount=' ; then
    # set default mount device if mountdev is not set in othbootargs env
    mountdev=mmcblk0p4
    # echo Using default mountdev: $mountdev
else
    mountdev=`echo $a | /bin/sed -r 's/.*(mount=[^ ]+) .*/\1/'`
    echo Using specified mountdev: $mountdev
fi

partnum=`echo $mountdev | /usr/bin/awk '{print substr($0,length())}'`
echo partnum: $partnum

/bin/mknod /dev/$mountdev b 179 $partnum
/bin/mount /dev/$mountdev /mnt

# ima emv mode: fix or enforce
ima_fix='evm=fix'

if echo $a | /bin/grep -q $ima_fix; then
    echo "Creating keys"
    /bin/keyctl add secure kmk-master "new 32" @u > /dev/null
    /bin/keyctl pipe `/bin/keyctl search @u secure kmk-master` > /mnt/etc/secure_key.blob
    /bin/keyctl add encrypted evm-key "new secure:kmk-master 32" @u > /dev/null
    /bin/keyctl pipe `/bin/keyctl search @u encrypted evm-key` > /mnt/etc/encrypted_key.blob

    /bin/chmod 1400 /mnt/etc/secure_key.blob
    /bin/chmod 1400 /mnt/etc/encrypted_key.blob
    /bin/chattr =i /mnt/etc/secure_key.blob
    /bin/chattr =i /mnt/etc/encrypted_key.blob
else
    echo "Loading blobs"
    /bin/keyctl add secure kmk-master "load `/bin/cat /mnt/etc/secure_key.blob`" @u > /dev/null
    /bin/keyctl add encrypted evm-key "load `/bin/cat /mnt/etc/encrypted_key.blob`" @u > /dev/null
fi

echo "1" > /sys/kernel/security/evm

if echo $a | /bin/grep -q $ima_fix; then
    echo "Labelling files in fix mode. This will take few minutes. Reboot once done"
    usr/bin/find /mnt/ -type f -exec head -c 1 '{}' > /dev/null \;
    echo "Attributes labeled."
    #echo b > /proc/sysrq-trigger
    #/sbin/reboot
fi

exec /bin/busybox switch_root /mnt /sbin/init
