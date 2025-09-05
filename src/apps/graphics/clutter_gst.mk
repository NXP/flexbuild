# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GStreamer integration library for Clutter
# clutter-gst is an integration library for using GStreamer with Clutter.
# It provides a GStreamer sink to upload frames to GL and an actor that implements the ClutterGstPlayer interface using playbin.
# http://www.clutter-project.org

# depends on clutter-1.0 which depends on cogl-1.0
# depends on gstreamer1.0-plugins-base gstreamer1.0-plugins-bad clutter-1.0 libgudev

#clutter_gst:
clutter_gst: gst_plugins_bad cogl libdrm
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,clutter_gst,apps/graphics,submod) && \
	 $(call patch_apply,clutter_gst,apps/graphics) && \
	 $(call fbprint_b,"clutter_gst") && \
	 sudo cp -Pf $(DESTDIR)/usr/lib/{libcogl.so*,libdrm.so*,libgst*.so*} $(RFSDIR)/usr/lib && \
	 sudo cp -rf $(DESTDIR)/usr/include/cogl $(RFSDIR)/usr/include && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgbm.so,libcogl.so,libgstallocators-1.0.so*,libclutter-gst-3.0.so.0} && \
	 \
	 cd $(GRAPHICSDIR)/clutter_gst && \
	 sed -i 's/noinst_PROGRAMS/bin_PROGRAMS/' examples/Makefile.am && \
	 sed -i 's/autoreconf -v --install/autoreconf --install/g' autogen.sh && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/gstreamer-1.0 \
			-I$(DESTDIR)/usr/include/clutter-1.0 -I$(RFSDIR)/usr/include" && \
	 export GST_PLUGIN_SCANNER_1_0=$(GRAPHICSDIR)/clutter_gst/gst-plugin-scanner-dummy && \
	 \
	 [ -f Makefile ] && $(MAKE) distclean &>/dev/null || true && \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu $(LOG_MUTE) && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--enable-introspection=no \
		--disable-gtk-doc \
		--disable-static \
		--enable-nls \
		--prefix=/usr $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"clutter_gst")
