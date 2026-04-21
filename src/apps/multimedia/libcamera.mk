# Copyright 2025-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A complex camera support library for Linux, Android, and ChromeOS
# imx95 imx8mm imx8ulp imx8mq

ifeq ($(CONFIG_SOC_IMX95),y)
  DEP_LIBCAM = mali_imx
else ifeq ($(CONFIG_SOC_IMX8),y)
  DEP_LIBCAM = gpu_viv
else
  DEP_LIBCAM =
endif

#libcamera:
libcamera: libdrm gstreamer gst_plugins_base $(DEP_LIBCAM)
	@$(call download_repo,libcamera,apps/multimedia)
	 $(call patch_apply,libcamera,apps/multimedia)
	 $(call fbprint_b,"libcamera")
	 cd $(MMDIR)/libcamera
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross
	 rm -rf build
	 export PATH=/usr/lib/qt6/libexec:$(PATH)
	 install -m 644 $(DESTDIR)/usr/lib/libgstbase-1.0* $(RFSDIR)/usr/lib/
	 install -m 644 $(DESTDIR)/usr/lib/libgstallocators-1.0* $(RFSDIR)/usr/lib/
	 install -m 644 $(DESTDIR)/usr/lib/libEGL.so.* $(RFSDIR)/usr/lib/
	 if [ "$(CONFIG_SOC_IMX8)" = "y" ]; then
		install -m 644 $(DESTDIR)/usr/lib/libGAL.so* $(RFSDIR)/usr/lib/
		install -m 644 $(DESTDIR)/usr/lib/libdrm.so* $(RFSDIR)/usr/lib/
		install -m 644 $(DESTDIR)/usr/lib/libgbm.so* $(RFSDIR)/usr/lib/
		install -m 644 $(DESTDIR)/usr/lib/libgbm_viv.so* $(RFSDIR)/usr/lib/
	 fi
	 if [ -d "$(DESTDIR)/usr/include/libpisp" ]; then
		mkdir -p "$(RFSDIR)/usr/include/libpisp"
		cp -r "$(DESTDIR)/usr/include/libpisp/." "$(RFSDIR)/usr/include/libpisp/"
		install -m 644 $(DESTDIR)/usr/lib/libpisp.so* "$(RFSDIR)/usr/lib"
	 fi
	 meson setup build \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		-Dpipelines=imx8-isi,mali-c55,simple,uvcvideo,nxp/neo \
		-Dv4l2=enabled \
		-Dcam=enabled \
		-Dlc-compliance=disabled \
		-Dtest=false \
		-Ddocumentation=disabled \
		-Dgstreamer=enabled \
		-Dpycamera=enabled $(LOG_MUTE)
	 ninja -C build install -v $(LOG_MUTE)
	 $(call fbprint_d,"libcamera")
