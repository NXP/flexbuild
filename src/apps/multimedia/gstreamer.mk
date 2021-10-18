# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# https://gstreamer.freedesktop.org

# GStreamer 1.0 framework for streaming media.
# GStreamer is a multimedia framework for encoding and decoding video and sound.
# It supports a wide range of formats including mp3, ogg, avi, mpeg and quicktime.

# i.MX fork of Gstreamer for customizations


gstreamer:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gstreamer") && \
	 $(call repo-mngr,fetch,gstreamer,apps/multimedia) && \
         if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
             bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
         fi && \
	 cd $(MMDIR)/gstreamer && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(DESTDIR)/usr/local/lib/pkgconfig && \
	 export HAVE_PTP_HELPER_CAPABILITIES=0 && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > $(MMDIR)/gstreamer/cross-compilation.conf && \
	 mkdir -p build && \
	 meson build -Dc_args="--sysroot=$(RFSDIR) -I$(DESTDIR)/usr/local/include -Dexamples=disabled \
			       -Ddbghelp=disabled -Dgtk_doc=disabled -Dtests=disabled -Dnls=disabled" \
		-Dc_link_args="-L$(DESTDIR)/usr/local/lib -L$(RFSDIR)/lib/aarch64-linux-gnu" \
	        --prefix=/usr --buildtype=release --cross-file cross-compilation.conf && \
	 ninja -j $(JOBS) -C build install && \
	 $(call fbprint_d,"gstreamer")
endif
endif
