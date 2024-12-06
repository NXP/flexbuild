# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GStreamer integration library for Clutter
# clutter-gst is an integration library for using GStreamer with Clutter.
# It provides a GStreamer sink to upload frames to GL and an actor that implements the ClutterGstPlayer interface using playbin.
# http://www.clutter-project.org

# depends on clutter-1.0 which depends on cogl-1.0
# depends on gstreamer1.0-plugins-base gstreamer1.0-plugins-bad clutter-1.0 libgudev

clutter_gst:
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"clutter_gst") && \
	 $(call repo-mngr,fetch,clutter_gst,apps/graphics) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgstplay-1.0.so.0 ]; then \
	     bld gst_plugins_bad -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libcogl.so ]; then \
	     bld cogl -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libdrm.so ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 sudo cp -Pf $(DESTDIR)/usr/lib/{libGLESv2.so*,libVSC.so,libEGL.so*,libGAL.so*,libgbm.so*,libcogl.so*,libdrm.so*,libgst*.so*} \
	 $(RFSDIR)/usr/lib && \
	 sudo cp -rf $(DESTDIR)/usr/include/cogl $(RFSDIR)/usr/include && \
	 sudo cp $(DESTDIR)/usr/lib/libgbm_viv.so* $(RFSDIR)/usr/lib && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgbm.so,libcogl.so,libgstallocators-1.0.so*,libclutter-gst-3.0.so.0} && \
	 \
	 cd $(GRAPHICSDIR)/clutter_gst && \
	 if [ ! -f .patchdone ]; then \
	    git am $(FBDIR)/patch/clutter_gst/*.patch && touch .patchdone; \
	 fi && \
	 sed -i 's/noinst_PROGRAMS/bin_PROGRAMS/' examples/Makefile.am && \
	 export CFLAGS="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/gstreamer-1.0 \
			-I$(DESTDIR)/usr/include/clutter-1.0 -I$(RFSDIR)/usr/include" && \
	 export GST_PLUGIN_SCANNER_1_0=$(GRAPHICSDIR)/clutter_gst/gst-plugin-scanner-dummy && \
	 \
	 ./autogen.sh --prefix=/usr --host=aarch64-linux-gnu && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--enable-introspection=no \
		--disable-gtk-doc \
		--disable-static \
		--enable-nls \
		--prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"clutter_gst")
