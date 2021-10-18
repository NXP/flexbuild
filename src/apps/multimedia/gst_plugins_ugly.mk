# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://gstreamer.freedesktop.org


gst_plugins_ugly:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gst_plugins_ugly") && \
	 $(call repo-mngr,fetch,gst_plugins_ugly,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_ugly && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	    bld -c gst_plugins_base -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	fi && \
	mkdir -p build && \
	meson build \
		-Dc_args="-I$(RFSDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -ludev -lpthread -lgstvideo-1.0" \
		--prefix=/usr --buildtype=release \
		--cross-file cross-compilation.conf \
		-Dx264=enabled \
		-Dmpeg2dec=enabled \
		-Dsidplay=disabled && \
	ninja -j $(JOBS) -C build install && \
	$(call fbprint_d,"gst_plugins_ugly")
endif
endif
