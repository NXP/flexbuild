# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# A GStreamer NNstreamer pipelines real-time profiling plugin

# Depend: gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad libgpuperfcnt perf

#nnshark:
nnshark: gst_plugins_bad libgpuperfcnt
	@[ $${MACHINE:0:5} != imx8m ] && exit || \
	 $(call download_repo,nnshark,apps/ml,submod) && \
	 $(call patch_apply,nnshark,apps/ml) && \
	 $(call fbprint_b,"nnshark") && \
	 export CPPFLAGS="-I$(DESTDIR)/usr/include" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -Wl,-rpath-link,$(DESTDIR)/usr/lib" && \
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
