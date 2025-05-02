# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://gstreamer.freedesktop.org


gst_plugins_ugly: gst_plugins_base
ifeq ($(CONFIG_GST_PLUGINS_UGLY),y)
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:7} != ls1028a -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call repo-mngr,fetch,gst_plugins_ugly,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_ugly && \
	 export CROSS=$(CROSS_COMPILE) && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	     bld gst_plugins_base -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"gst_plugins_ugly") && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dc_args="-I$(RFSDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -ludev \
			-lpthread -lgstvideo-1.0 -lgstsdp-1.0" \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		--strip \
		-Dx264=enabled \
		-Dmpeg2dec=enabled \
		-Dsidplay=disabled \
		-Dorc=enabled $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 $(call fbprint_d,"gst_plugins_ugly")
endif
