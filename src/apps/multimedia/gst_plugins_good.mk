# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




gst_plugins_good: gst_plugins_base libdrm
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,gst_plugins_good,apps/multimedia) && \
	 $(call patch_apply,gst_plugins_good,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_good && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 sudo cp -fr $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include && \
	 sudo cp -fa $(DESTDIR)/usr/lib/libgsttag-1.0.so* $(RFSDIR)/usr/lib && \
	 $(call fbprint_b,"gst_plugins_good") && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dc_args="-I$(DESTDIR)/usr/include/gstreamer-1.0 \
			  -I$(DESTDIR)/usr/lib/gstreamer-1.0/include -I$(DESTDIR)/usr/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib \
			-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -lgstnet-1.0 -lgstrtp-1.0 -lgstrtsp-1.0 \
			-lgstaudio-1.0 -lgstvideo-1.0 -lgstallocators-1.0 -lgstpbutils-1.0 -lEGL -lgbm" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -lgstnet-1.0 \
			-lgstrtp-1.0 -lgstrtsp-1.0 -lgstaudio-1.0 -lgstvideo-1.0 -lgstallocators-1.0 \
			-lgstpbutils-1.0 -lEGL -lgbm" \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		--strip \
		-Dasm=disabled \
		-Dbz2=enabled \
		-Dcairo=enabled \
		-Ddv1394=disabled \
		-Dflac=enabled \
		-Dgdk-pixbuf=enabled \
		-Dgtk3=enabled \
		-Dv4l2-gudev=enabled \
		-Djack=disabled \
		-Djpeg=enabled \
		-Dlame=enabled \
		-Dpng=enabled \
		-Dv4l2-libv4l2=disabled \
		-Dmpg123=enabled \
		-Dorc=enabled \
		-Dpulse=enabled \
		-Dqt5=disabled \
		-Drpicamsrc=disabled \
		-Dsoup=enabled \
		-Dspeex=enabled \
		-Dtaglib=enabled \
		-Dv4l2=enabled \
		-Dv4l2-probe=true \
		-Dvpx=disabled \
		-Dwavpack=disabled \
		-Dximagesrc=enabled \
		-Dximagesrc-xshm=enabled \
		-Dximagesrc-xfixes=enabled \
		-Dximagesrc-xdamage=enabled \
		\
		-Dexamples=disabled \
		-Dnls=enabled \
		-Ddoc=disabled \
		-Daalib=disabled \
		-Ddirectsound=disabled \
		-Ddv=disabled \
		-Dlibcaca=disabled \
		-Doss=enabled \
		-Doss4=disabled \
		-Dosxaudio=disabled \
		-Dosxvideo=disabled \
		-Dshout2=disabled \
		-Dtwolame=disabled \
		-Dwaveform=disabled $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 $(call fbprint_d,"gst_plugins_good")
