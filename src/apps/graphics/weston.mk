# Copyright 2017-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# A lightweight and functional Wayland compositor.
#
# Weston is the reference implementation of a Wayland compositor
#
# http://wayland.freedesktop.org


ifeq ($(CONFIG_SOC_IMX95),y)
  DEP_WESTON = mali_imx imx_dpu_g2d_v2
else ifeq ($(CONFIG_SOC_IMX8M),y)
  DEP_WESTON = gpu_viv imx_gpu_g2d
else ifeq ($(CONFIG_SOC_IMX8QMMEK),y)
  DEP_WESTON = gpu_viv imx_dpu_g2d_v1
else ifeq ($(CONFIG_SOC_LS1028ARDB),y)
  DEP_WESTON = gpu_viv imx_gpu_g2d
else ifeq ($(CONFIG_SOC_IMX91),y)
  DEP_WESTON = imx_pxp_g2d
else ifeq ($(CONFIG_SOC_IMX93),y)
  DEP_WESTON = imx_pxp_g2d
else
  DEP_WESTON =
endif

#weston:
weston: $(DEP_WESTON) libdrm wayland_protocols
	 @$(call download_repo,weston,apps/graphics)
	 $(call patch_apply,weston,apps/graphics)
	 export PKG_CONFIG_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig
	 export PKG_CONFIG_SYSROOT_DIR=$(RFSDIR)
	 export LD_LIBRARY_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu:$(DESTDIR)/usr/lib:$(RFSDIR)/usr/lib
	 $(call fbprint_b,"weston")
	 cd $(GRAPHICSDIR)/weston
	 rm -rf build_$(DISTROTYPE)_$(ARCH)
	 mkdir -p $(RFSDIR)/usr/include/libdrm
	 cp -af $(DESTDIR)/usr/include/libdrm/drm_fourcc.h $(RFSDIR)/usr/include/libdrm/
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross
	 sed 's%@STAGING_DIR@%$(FBDIR)%g' $(FBDIR)/src/system/meson.native > meson.native
	 PKG_CONFIG_LIBDIR="$(PKG_CONFIG_LIBDIR)" \
	 PKG_CONFIG_SYSROOT_DIR="$(PKG_CONFIG_SYSROOT_DIR)" \
	 PYTHONNOUSERSITE=y meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file=meson.cross \
		--native-file=meson.native \
		--prefix=/usr --libdir=lib \
		--default-library=shared \
		--buildtype=release \
		-Dxwayland=true \
		-Dpipewire=false \
		-Dsimple-clients=all \
		-Ddemo-clients=true \
		-Drenderer-gl=true \
		-Dbackend-headless=false \
		-Dimage-jpeg=true \
		-Drenderer-g2d=true \
		-Dbackend-drm=true \
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
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -Wl,-rpath-link=$(DESTDIR)/usr/lib -Wl,-rpath-link=$(RFSDIR)/usr/lib/aarch64-linux-gnu" $(LOG_MUTE)
	 ninja install -C build_$(DISTROTYPE)_$(ARCH) $(LOG_MUTE)
	 mkdir -p $(DESTDIR)/etc/xdg/weston $(DESTDIR)/etc/systemd/system/graphical.target.wants $(DESTDIR)/etc/default
	 mkdir -p $(DESTDIR)/usr/share/applications $(DESTDIR)/usr/share/icons/hicolor/48x48/apps $(DESTDIR)/lib/systemd/system
	 mkdir -p $(DESTDIR)/etc/systemd/system/sockets.target.wants
	 mkdir -p $(DESTDIR)/etc/pam.d/
	 cp -f $(FBDIR)/src/system/weston/weston.ini $(DESTDIR)/etc/xdg/weston/weston.ini
	 install -m 644 $(FBDIR)/src/system/weston/weston $(DESTDIR)/etc/default/weston
	 install -m 644 $(FBDIR)/src/system/weston/weston.service $(DESTDIR)/lib/systemd/system/
	 install -m 644 $(FBDIR)/src/system/weston/weston-autologin $(DESTDIR)/etc/pam.d/
	 install -m 644 $(FBDIR)/src/system/weston/weston.socket $(DESTDIR)/lib/systemd/system/
	 ln -sf /lib/systemd/system/weston.socket $(DESTDIR)/etc/systemd/system/sockets.target.wants/weston.socket
	 install -m 644 $(FBDIR)/src/system/weston/weston.png $(DESTDIR)/usr/share/icons/hicolor/48x48/apps/weston.png
	 install -m 644 $(FBDIR)/src/system/weston/weston.desktop $(DESTDIR)/usr/share/applications/weston.desktop
	 $(call fbprint_d,"weston")
