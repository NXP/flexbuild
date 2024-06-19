# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://gstreamer.freedesktop.org


gst_plugins_ugly:
ifeq ($(CONFIG_GST_PLUGINS_UGLY),y)
	@[ $(DISTROVARIANT) != desktop -o $(DESTARCH) != arm64 ] && exit || \
	 $(call fbprint_b,"gst_plugins_ugly") && \
	 $(call repo-mngr,fetch,gst_plugins_ugly,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_ugly && \
	 export CROSS=$(CROSS_COMPILE) && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	     bld gst_plugins_base -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
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
		-Dorc=enabled && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"gst_plugins_ugly")
endif
