# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://wiki.gnome.org/Apps/Cheese
# Take photos and videos with your webcam, with fun graphical effects


# depend: libclutter-1.0-dev libclutter-gst-3.0-dev libclutter-gtk-1.0-dev libgnome-desktop-3-dev
#         libcanberra-dev libcanberra-gtk3-dev libcheese-gtk-dev


cheese:
ifeq ($(CONFIG_CHEESE), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"cheese") && \
	 $(call repo-mngr,fetch,cheese,apps/multimedia) && \
	 cd $(MMDIR)/cheese && \
	 if [ ! -f .patchdone ]; then \
             git am $(FBDIR)/src/apps/multimedia/patch/cheese/*.patch && touch .patchdone; \
         fi && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	     bld -c gst_plugins_base -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstv4l2codecs.so ]; then \
	     bld -c gst_plugins_bad -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
         fi && \
	 sudo cp -rf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include; \
	 rm -rf build && mkdir -p build && \
	 meson build \
		-Dc_args="-I$(RFSDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		--prefix=/usr --buildtype=release \
		--cross-file cross-compilation.conf \
		-Dintrospection=false -Dgtk_doc=false -Dman=false && \
	 ninja -C build install && \
	 $(call fbprint_d,"cheese")
endif
endif
