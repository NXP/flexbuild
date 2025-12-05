# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# https://wiki.gnome.org/Apps/Cheese
# Take photos and videos with your webcam, with fun graphical effects


# depends on gstreamer1.0 gstreamer1.0-plugins-base libcanberra gtk4 clutter-1.0 clutter-gst-3.0
#	  libclutter-gtk-1.0-dev vala-native gnome-desktop libxml2-native gdk-pixbuf-native itstool-native


#cheese:
cheese: clutter_gst gst_plugins_bad
	@[ $${MACHINE:0:4} != imx8 -a $${MACHINE:0:5} != imx95 ] && exit || \
	 $(call download_repo,cheese,apps/multimedia,submod) && \
	 $(call patch_apply,cheese,apps/multimedia) && \
	 cd $(MMDIR)/cheese && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 $(call fbprint_b,"cheese") && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstallocators-1.0.so.0 && \
	 sudo cp -rf $(DESTDIR)/usr/include/cogl $(RFSDIR)/usr/include && \
	 \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
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
		-Dman=false $(LOG_MUTE) && \
	 ninja -v -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 rm -f $(DESTDIR)/usr/share/icons/hicolor/scalable/apps/org.gnome.Cheese.svg && \
	 rm -f $(DESTDIR)/usr/share/icons/hicolor/symbolic/apps/org.gnome.Cheese-symbolic.svg && \
	 $(call fbprint_d,"cheese")
