# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A lightweight and functional Wayland compositor.

# Weston is the reference implementation of a Wayland compositor

# http://wayland.freedesktop.org

# version：12.0.3

weston:
ifeq ($(CONFIG_WESTON),y)
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"weston") && \
	 $(call repo-mngr,fetch,weston,apps/graphics) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/libdrm ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     bld wayland -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/share/wayland-protocols ]; then \
	     bld wayland_protocols -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/EGL ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 cd $(GRAPHICSDIR)/weston && \
	 sed -i 's/0.63/0.61/' meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file=meson.cross \
		--prefix=/usr --libdir=lib \
		--default-library=shared \
		--buildtype=release \
		-Dxwayland=true \
		-Dpipewire=false \
		-Dsimple-clients=all \
		-Ddemo-clients=true \
		-Ddeprecated-color-management-colord=false \
		-Drenderer-gl=true \
		-Dbackend-headless=false \
		-Dimage-jpeg=true \
		-Drenderer-g2d=true \
		-Dbackend-drm=true \
		-Dlauncher-libseat=true \
		-Ddeprecated-launcher-logind=false \
		-Dcolor-management-lcms=false \
		-Dbackend-pipewire=false \
		-Dbackend-rdp=false \
		-Dremoting=false \
		-Dscreenshare=true \
		-Dshell-desktop=true \
		-Dshell-fullscreen=true \
		-Dshell-ivi=true \
		-Dshell-kiosk=true \
		-Dsystemd=true \
		-Dbackend-drm-screencast-vaapi=false \
		-Dbackend-vnc=false \
		-Dbackend-wayland=false \
		-Dimage-webp=false \
		-Dbackend-x11=false \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -lgbm" && \
	 ninja install -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) && \
	 mkdir -p $(DESTDIR)/etc/xdg/weston $(DESTDIR)/etc/systemd/system/graphical.target.wants $(DESTDIR)/etc/default && \
	 mkdir -p $(DESTDIR)/usr/share/applications $(DESTDIR)/usr/share/icons/hicolor/48x48/apps $(DESTDIR)/lib/systemd/system && \
	 cp $(FBDIR)/src/system/weston/weston.ini $(DESTDIR)/etc/xdg/weston/weston.ini && \
	 install -m 644 $(FBDIR)/src/system/weston/weston $(DESTDIR)/etc/default/weston && \
	 install -m 644 $(FBDIR)/src/system/weston/weston.service $(DESTDIR)/lib/systemd/system/ && \
	 ln -sf /lib/systemd/system/weston.service $(DESTDIR)/etc/systemd/system/graphical.target.wants/weston.service && \
	 install -m 644 $(FBDIR)/patch/weston/weston.png $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/weston.png && \
	 install -m 644 $(FBDIR)/patch/weston/weston.desktop $(DESTDIR)/usr/share/applications/weston.desktop && \
	 $(call fbprint_d,"weston")
endif
