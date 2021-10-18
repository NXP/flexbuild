# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


wayland:
ifeq ($(CONFIG_WAYLAND), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"wayland") && \
	 $(call repo-mngr,fetch,wayland,apps/graphics) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 cd $(GRAPHICSDIR)/wayland && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu --disable-documentation --with-host-scanner && \
	 $(MAKE) && $(MAKE) install && \
	 $(call fbprint_d,"wayland")
endif
endif
