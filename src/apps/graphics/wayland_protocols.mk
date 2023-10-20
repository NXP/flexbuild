# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



wayland_protocols:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop -a $(MACHINE) != imx93evk ] && exit || \
	 $(call fbprint_b,"wayland_protocols") && \
	 $(call repo-mngr,fetch,wayland_protocols,apps/graphics) && \
	 cd $(GRAPHICSDIR)/wayland_protocols && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dtests=false \
		-Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=/usr \
		--buildtype=release \
		--cross-file meson.cross && \
	 DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"wayland_protocols")
