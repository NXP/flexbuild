# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



wayland_protocols:
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:7} != ls1028a -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"wayland_protocols") && \
	 $(call repo-mngr,fetch,wayland_protocols,apps/graphics) && \
	 cd $(GRAPHICSDIR)/wayland_protocols && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dtests=false \
		-Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=/usr \
		--buildtype=release \
		--cross-file meson.cross && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"wayland_protocols")
