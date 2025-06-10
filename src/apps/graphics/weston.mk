# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A lightweight and functional Wayland compositor.

# Weston is the reference implementation of a Wayland compositor

# http://wayland.freedesktop.org

# version：12.0.3

weston: libdrm wayland wayland_protocols gpu_viv
	@[ $(DISTROVARIANT) != desktop ] && exit || \
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
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 export LD_LIBRARY_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(DESTDIR)/usr/lib:$(RFSDIR)/usr/lib && \
	 $(call fbprint_b,"weston") && \
	 cd $(GRAPHICSDIR)/weston && \
	 sed -i 's/0.63/0.61/' meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 ln -sf $(RFSDIR)/lib/aarch64-linux-gnu/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 && \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 cp -rf $(DESTDIR)/usr/include/drm/drm_fourcc.h $(RFSDIR)/usr/include/libdrm/ && \
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
		-Dc_args="-I$(DESTDIR)/usr/include/drm -I$(DESTDIR)/usr/share/ -I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -lgbm -lgbm_viv -lGAL" $(LOG_MUTE) && \
	 ninja install -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE) && \
	 mkdir -p $(DESTDIR)/etc/xdg/weston $(DESTDIR)/etc/systemd/system/graphical.target.wants $(DESTDIR)/etc/default && \
	 mkdir -p $(DESTDIR)/usr/share/applications $(DESTDIR)/usr/share/icons/hicolor/48x48/apps $(DESTDIR)/lib/systemd/system && \
	 mkdir -p $(DESTDIR)/etc/systemd/system/sockets.target.wants && \
	 mkdir -p $(DESTDIR)/etc/pam.d/ && \
	 cp $(FBDIR)/src/system/weston/weston.ini $(DESTDIR)/etc/xdg/weston/weston.ini && \
	 install -m 644 $(FBDIR)/src/system/weston/weston $(DESTDIR)/etc/default/weston && \
	 install -m 644 $(FBDIR)/src/system/weston/weston.service $(DESTDIR)/lib/systemd/system/ && \
	 install -m 644 $(FBDIR)/src/system/weston/weston-autologin $(DESTDIR)/etc/pam.d/ && \
	 install -m 644 $(FBDIR)/src/system/weston/weston.socket $(DESTDIR)/lib/systemd/system/ && \
	 ln -sf /lib/systemd/system/weston.socket $(DESTDIR)/etc/systemd/system/sockets.target.wants/weston.socket && \
	 install -m 644 $(FBDIR)/src/system/weston/weston.png $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/weston.png && \
	 install -m 644 $(FBDIR)/src/system/weston/weston.desktop $(DESTDIR)/usr/share/applications/weston.desktop && \
	 rm -rf /lib/ld-linux-aarch64.so.1 && \
	 $(call fbprint_d,"weston")
