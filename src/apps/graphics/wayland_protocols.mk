# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



wayland_protocols:
	@$(call download_repo,wayland_protocols,apps/graphics)
	$(call patch_apply,wayland_protocols,apps/graphics)
	$(call fbprint_b,"wayland_protocols")
	cd $(GRAPHICSDIR)/wayland_protocols
	rm -rf build_$(DISTROTYPE)_$(ARCH)
	ed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross
	sed 's%@STAGING_DIR@%$(FBDIR)%g' $(FBDIR)/src/system/meson.native > meson.native
	meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dtests=false \
		-Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
		--prefix=/usr \
		--buildtype=release \
		--native-file=meson.native \
		--cross-file meson.cross $(LOG_MUTE)
	DESTDIR=$(RFSDIR) ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE)
	DESTDIR=$(DESTDIR) ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE)
	cp -af $(DESTDIR)/usr/share/pkgconfig/wayland-protocols.pc $(RFSDIR)/usr/share/pkgconfig/
	cp -af $(DESTDIR)/usr/share/wayland-protocols $(RFSDIR)/usr/share/
	$(call fbprint_d,"wayland_protocols")
