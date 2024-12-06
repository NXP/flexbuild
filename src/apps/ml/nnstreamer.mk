# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NNStreamer - Stream Pipeline Paradigm for Neural Network Applications
# NNStreamer is a GStreamer plugin allowing to construct neural network applications with stream pipeline paradigm.

nnstreamer:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"nnstreamer") && \
	 $(call repo-mngr,fetch,nnstreamer,apps/ml) && \
	 cd $(MLDIR)/nnstreamer && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/nnstreamer/*.patch && touch .patchdone; \
         fi && \
	 mkdir -p $(DESTDIR)/usr/lib/pkgconfig && \
	 sed -i 's/cpp_std=c++14/cpp_std=c++17/' meson.build && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstopengl.so ]; then \
	     bld gst_plugins_base -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtensorflow-lite.so ]; then \
	     bld tflite -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libnnstreamer-edge.so ]; then \
	     bld nnstreamer_edge -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libtvm.so ]; then \
	     bld tvm -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR) -march=armv8-a+crc+crypto" && \
	 export CXXFLAGS="-O2 -pipe -g -fPIC -feliminate-unused-debug-types -fcanon-prefix-map" && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file meson.cross \
		--prefix=/usr --buildtype=release \
		--strip \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include" \
		-Dcpp_args="-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include -I$(MLDIR)/tvm/3rdparty/dmlc-core/include \
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
		-Dtvm-support=enabled && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 $(call fbprint_d,"nnstreamer")
