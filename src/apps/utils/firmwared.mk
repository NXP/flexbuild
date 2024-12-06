# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# The Linux Firmware Loader Daemon monitors the kernel for firmware requests and uploads the firmware blobs it has via the sysfs interface
# https://github.com/teg/firmwared

# DEPENDS: glib-2.0 systemd

# needed to load camera ap1302.fw for imx93evk


firmwared:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"firmwared") && \
	 $(call repo-mngr,fetch,firmwared,apps/utils) && \
	 cd $(UTILSDIR)/firmwared && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)  \
		 -march=armv8-a+crc+crypto -mbranch-protection=standard -O2 \
		 -fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat \
		 -Wformat-security -Werror=format-security -Wno-error=maybe-uninitialized" && \
	 export CFLAGS="-I$(DESTDIR)/usr/include/libdrm -I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--prefix=/usr \
		--disable-silent-rules \
		--with-libtool-sysroot=$(RFSDIR) && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 mkdir -p $(DESTDIR)/usr/lib/systemd/system $(DESTDIR)/etc/systemd/system/multi-user.target.wants && \
	 install -m 0644 $(FBDIR)/src/system/firmwared.service $(DESTDIR)/usr/lib/systemd/system/ && \
	 ln -sf /usr/lib/systemd/system/firmwared.service $(DESTDIR)/etc/systemd/system/multi-user.target.wants/firmwared.service && \
	 $(call fbprint_d,"firmwared")
