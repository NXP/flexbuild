# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# depend imx-codec imx-parser libdrm gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad

PLATFORM ?= MX8


imx_gst_plugin:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"imx_gst_plugin") && \
	 $(call repo-mngr,fetch,imx_gst_plugin,apps/multimedia) && \
	 cd $(MMDIR)/imx_gst_plugin && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	 if [ ! -d $(RFSDIR)/usr/include/libdrm ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstv4l2codecs.so ]; then \
             bld -c gst_plugins_bad -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 rm -rf build && mkdir -p build && \
	 meson build \
	      -Dplatform=$(PLATFORM) \
	      -Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/imx -I$(RFSDIR)/usr/include/gstreamer-1.0" \
	      -Dc_link_args="-L$(RFSDIR)/usr/lib" \
	      --prefix=/usr --buildtype=release --cross-file cross-compilation.conf && \
	 ninja -j $(JOBS) -C build install && \
	 $(call fbprint_d,"imx_gst_plugin")
endif
endif
