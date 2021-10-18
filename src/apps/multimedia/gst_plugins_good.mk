# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




gst_plugins_good:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gst_plugins_good") && \
	 $(call repo-mngr,fetch,gst_plugins_good,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_good && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	     bld -c gst_plugins_base -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libdrm.so ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/lib/gstreamer-1.03 ]; then \
	     sudo cp -rf $(DESTDIR)/usr/lib/libgst* $(DESTDIR)/usr/lib/gstreamer-1.0 $(RFSDIR)/usr/lib && \
	     sudo cp -rf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include && \
	     sudo cp -rf $(DESTDIR)/usr/include/libdrm $(RFSDIR)/usr/include; \
	 fi && \
	 if [ -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstnet-1.0.so ]; then \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstnet-1.0.so; \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstrtp-1.0.so; \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstrtsp-1.0.so; \
	 fi && \
	 mkdir -p build && \
	 meson build \
		-Dc_args="-I$(DESTDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -lgstnet-1.0 -lgstrtp-1.0 -lgstrtsp-1.0 -lgstvideo-1.0 -lgstallocators-1.0" \
		--prefix=/usr --buildtype=release \
		--cross-file cross-compilation.conf \
		-Daalib=disabled \
		-Ddirectsound=disabled \
		-Ddv=disabled \
		-Dlibcaca=disabled \
		-Doss=enabled \
		-Doss4=disabled \
		-Dosxaudio=disabled \
		-Dosxvideo=disabled \
		-Dqt5=disabled \
		-Dshout2=disabled \
		-Dtwolame=disabled \
		-Dwaveform=disabled \
		-Dmpg123=enabled \
		-Djpeg=enabled \
		-Dsoup=enabled \
		-Dflac=enabled \
		-Dv4l2-gudev=enabled \
		-Dv4l2=enabled -Dv4l2-probe=true \
		-Dv4l2-libv4l2=enabled && \
	 ninja -j $(JOBS) -C build install && \
	 $(call fbprint_d,"gst_plugins_good")
endif
endif
