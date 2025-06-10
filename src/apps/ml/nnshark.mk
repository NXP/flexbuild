# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A GStreamer NNstreamer pipelines real-time profiling plugin

# Depend: gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad libgpuperfcnt perf

nnshark: gst_plugins_bad libgpuperfcnt
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,nnshark,apps/ml) && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgstplay-1.0.so.0 ]; then \
	     bld gst_plugins_bad -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgpuperfcnt.so ]; then \
	     bld libgpuperfcnt -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"nnshark") && \
	 sudo cp -rf $(DESTDIR)/usr/lib/libgpuperfcnt.so* $(RFSDIR)/usr/lib/ && \
	 sudo cp -rf $(DESTDIR)/usr/include/gpuperfcnt $(RFSDIR)/usr/include/ && \
	 cd $(MLDIR)/nnshark && \
	 sed -i 's/--exclude=gtkdocize//' autogen.sh && \
	 ./autogen.sh --noconfigure --prefix=/usr --host=aarch64-linux-gnu $(LOG_MUTE) && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	 	--host=aarch64-linux-gnu \
		--disable-graphviz \
		--disable-gtk-doc \
		--prefix=/usr $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"nnshark")
