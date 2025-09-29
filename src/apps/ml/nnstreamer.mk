# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NNStreamer - Stream Pipeline Paradigm for Neural Network Applications
# NNStreamer is a GStreamer plugin allowing to construct neural network applications with stream pipeline paradigm.

#nnstreamer:
nnstreamer: gst_plugins_base tflite nnstreamer_edge
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,nnstreamer,apps/ml) && \
	 $(call patch_apply,nnstreamer,apps/ml) && \
	 cd $(MLDIR)/nnstreamer && \
	 rm -rf build_debian_arm64 && \
	 mkdir -p $(DESTDIR)/usr/lib/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 \
	 $(call fbprint_b,"nnstreamer") && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -fcanon-prefix-map" && \
	 cp -af $(DESTDIR)/usr/lib/libgsttag-1.0.so* $(RFSDIR)/usr/lib && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file meson.cross \
		--prefix=/usr --buildtype=release \
		--strip \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-Dcpp_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include \
				-I$(RFSDIR)/usr/lib/aarch64-linux-gnu/python3-numpy/numpy/_core/include \
				-I$(MLDIR)/tvm/3rdparty/dmlc-core/include \
			    -I$(MLDIR)/tflite/build_debian_arm64/abseil-cpp -I$(MLDIR)/tflite \
			    -Wno-error=comment -Wno-sign-compare -Wno-error=unused-parameter -Wno-error=redundant-decls" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
		-Denable-float16=true \
		-Denable-test=true \
		-Dinstall-test=true \
		-Dtflite2-custom-support=disabled \
		-Dflatbuf-support=disabled \
		-Dgrpc-support=disabled \
		-Dprotobuf-support=enabled \
		-Dpython3-support=enabled \
		-Dnnstreamer-edge-support=enabled \
		-Dtflite2-support=enabled \
		-Dtvm-support=disabled $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 $(call fbprint_d,"nnstreamer")
