# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://wiki.gnome.org/Apps/Cheese
# Take photos and videos with your webcam, with fun graphical effects


# depends on gstreamer1.0 gstreamer1.0-plugins-base libcanberra gtk4 clutter-1.0 clutter-gst-3.0
#	  libclutter-gtk-1.0-dev vala-native gnome-desktop libxml2-native gdk-pixbuf-native itstool-native


cheese:
	@[ $(DISTROVARIANT) != desktop -o $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"cheese") && \
	 $(call repo-mngr,fetch,cheese,apps/multimedia) && \
	 cd $(MMDIR)/cheese && \
	 if [ ! -f .patchdone ]; then \
	      git am $(FBDIR)/patch/cheese/*.patch && touch .patchdone; \
	 fi && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgstplay-1.0.so.0 ]; then \
	     bld gst_plugins_bad -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libclutter-gst-3.0.so ]; then \
	     bld clutter_gst -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstallocators-1.0.so.0 && \
	 sudo cp -rf $(DESTDIR)/usr/include/cogl $(RFSDIR)/usr/include && \
	 \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dc_args="-I$(DESTDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include \
			  -I$(DESTDIR)/usr/include/clutter-gst-3.0" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -lgstbase-1.0 -lclutter-gst-3.0" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -lgstbase-1.0 -lclutter-gst-3.0" \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		--strip \
		-Dintrospection=false \
		-Dgtk_doc=false \
		-Dman=false && \
	 ninja -C build_$(DISTROTYPE)_$(ARCH) install && \
	 rm -f $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg && \
	 rm -f $(DESTDIR)/usr/share/icons/hicolor/symbolic/apps/org.gnome.Cheese-symbolic.svg && \
	 $(call fbprint_d,"cheese")
