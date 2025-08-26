# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A complex camera support library for Linux, Android, and ChromeOS
# imx95 imx8mm imx8ulp imx8mq

libcamera:
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,libcamera,apps/multimedia) && \
	 $(call patch_apply,libcamera,apps/multimedia) && \
	 $(call fbprint_b,"libcamera") && \
	 cd $(MMDIR)/libcamera && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 rm -rf build && \
	 export PATH=/usr/lib/qt6/libexec:$(PATH) && \
	 meson setup build \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		-Dpipelines=auto \
		-Dv4l2=enabled \
		-Dcam=enabled \
		-Dlc-compliance=disabled \
		-Dtest=false \
		-Ddocumentation=disabled \
		-Dgstreamer=enabled \
		-Dpycamera=enabled $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build install -v $(LOG_MUTE) && \
	 $(call fbprint_d,"libcamera")
