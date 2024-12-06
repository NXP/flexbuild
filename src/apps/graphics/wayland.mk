# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


wayland:
ifeq ($(CONFIG_WAYLAND),y)
	@[ $(SOCFAMILY) = LS -a $${MACHINE:0:7} != ls1028a -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"wayland") && \
	 $(call repo-mngr,fetch,wayland,apps/graphics) && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_LIBDIR=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 cd $(GRAPHICSDIR)/wayland && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a72%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/system/meson.cross > meson.cross && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Ddocumentation=false \
		-Dtests=false \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=/usr \
		--buildtype=release \
		--cross-file=meson.cross && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"wayland")
endif
