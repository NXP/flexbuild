# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Weston is the reference implementation of a Wayland compositor
# http://wayland.freedesktop.org


weston:
ifeq ($(CONFIG_WESTON),y)
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop -a $(MACHINE) != imx93evk ] && exit || \
	 $(call fbprint_b,"weston") && \
	 $(call repo-mngr,fetch,weston,apps/graphics) && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/libdrm ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     bld wayland -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/share/wayland-protocols ]; then \
	     bld wayland_protocols -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/EGL ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT) -f $(CFGLISTYML); \
	 fi && \
	 cd $(GRAPHICSDIR)/weston && \
	 rm -rf build_$(DISTROTYPE) && \
	 sudo cp -Prf --preserve=mode,timestamps $(DESTDIR)/usr/* $(RFSDIR)/usr/ && \
	 sed -i 's,native: false,native: true,' protocol/meson.build && \
	 sed -i 's/17.2/21.3.5/' $(DESTDIR)/usr/lib/pkgconfig/gbm.pc && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 \
	 PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig \
	 PYTHONNOUSERSITE=y PKG_CONFIG_SYSROOT_DIR=$(RFSDIR) \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file=meson.cross \
		--prefix=/usr --libdir=lib --default-library=shared --buildtype=release \
		-Dpipewire=false -Dimage-webp=false -Dlauncher-libseat=false -Dcolor-management-lcms=false \
		-Dbackend-drm-screencast-vaapi=false -Dbackend-rdp=false \
		-Dsystemd=true -Dlauncher-logind=true \
		-Drenderer-g2d=true \
		-Dxwayland=true \
		-Dimage-jpeg=true \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/local/include -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/lib/aarch64-linux-gnu -lgbm" && \
	 ninja install -j$(JOBS) -C build_$(DISTROTYPE)_$(ARCH) && \
	 echo OPTARGS=\" \" | sudo tee $(RFSDIR)/etc/default/weston && \
	 sudo install -d $(RFSDIR)/etc/xdg/weston && \
	 sudo cp $(FBDIR)/src/misc/weston/weston.ini $(RFSDIR)/etc/xdg/weston/ && \
	 if [ $(SOCFAMILY) = IMX ]; then \
	     sudo sed -i 's%DP%HDMI-A%g' $(RFSDIR)/etc/xdg/weston/weston.ini; \
	 fi && \
	 sudo install -m 755 $(FBDIR)/src/misc/weston/weston.sh $(RFSDIR)/etc/profile.d/ && \
	 sudo install -m 644 $(FBDIR)/src/misc/weston/weston.service $(RFSDIR)/lib/systemd/system/ && \
	 sudo ln -sf /lib/systemd/system/weston.service $(RFSDIR)/etc/systemd/system/multi-user.target.wants/weston.service && \
	 $(call fbprint_d,"weston")
endif
