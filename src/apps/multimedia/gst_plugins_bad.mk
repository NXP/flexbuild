# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# depends on libusb-1.0-0-dev libopencv-core-dev
# libopencv-stitching4.2 libopencv-contrib4.2 libdc1394-22-dev


gst_plugins_bad:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gst_plugins_bad") && \
	 $(call repo-mngr,fetch,gst_plugins_bad,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_bad && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(DESTDIR)/usr/share/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstvolume.so ]; then \
	     bld -c gst_plugins_base -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libdrm.so ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     bld -c wayland -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/share/pkgconfig/wayland-protocols.pc ]; then \
	     bld -c wayland_protocols -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libg2d.so ]; then \
	     bld -c imx_g2d -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstvideo-1.0.so ]; then \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstvideo-1.0.so && \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstallocators-1.0.so; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/share/wayland-protocols/unstable/alpha-compositing ]; then \
	     sudo mkdir -p $(RFSDIR)/usr/share/wayland-protocols/unstable/alpha-compositing && \
	     sudo mkdir -p $(RFSDIR)/usr/share/wayland-protocols/unstable/hdr10-metadata && \
	     sudo cp -f $(FBDIR)/src/apps/multimedia/patch/gst_plugins_bad/alpha-compositing-unstable-v1.xml \
	     $(RFSDIR)/usr/share/wayland-protocols/unstable/alpha-compositing && \
	     sudo cp -f $(FBDIR)/src/apps/multimedia/patch/gst_plugins_bad/hdr10-metadata-unstable-v1.xml \
	     $(RFSDIR)/usr/share/wayland-protocols/unstable/hdr10-metadata; \
	 fi && \
	 sudo cp -Prf --preserve=mode,timestamps $(DESTDIR)/usr/* $(RFSDIR)/usr/ && \
	 mkdir -p build && \
	 meson build \
		-Dc_args="-I$(DESTDIR)/usr/include/gstreamer-1.0 -I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/lib/gstreamer-1.0/include" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -ludev -lpthread" \
		--prefix=/usr --buildtype=release \
		--cross-file cross-compilation.conf \
		-Ddecklink=enabled \
		-Ddvb=enabled \
		-Dfbdev=enabled \
		-Dipcpipeline=enabled \
		-Dnetsim=enabled \
		-Dshm=enabled \
		-Daom=disabled \
		-Dandroidmedia=disabled \
		-Dapplemedia=disabled \
		-Dbs2b=disabled \
		-Dchromaprint=disabled \
		-Dd3dvideosink=disabled \
		-Ddirectsound=disabled \
		-Ddts=disabled \
		-Dfdkaac=disabled \
		-Dflite=disabled \
		-Dgme=disabled \
		-Dgsm=disabled \
		-Diqa=disabled \
		-Dkate=disabled \
		-Dladspa=disabled \
		-Dlv2=disabled \
		-Dmpeg2enc=disabled \
		-Dmplex=disabled \
		-Dmsdk=disabled \
		-Dmusepack=disabled \
		-Dofa=disabled \
		-Dopenexr=disabled \
		-Dopenmpt=disabled \
		-Dopenni2=disabled \
		-Dopensles=disabled \
		-Dsoundtouch=disabled \
		-Dspandsp=disabled \
		-Dsrt=disabled \
		-Dteletext=disabled \
		-Dwasapi=disabled \
		-Dwildmidi=disabled \
		-Dwinks=disabled \
		-Dwinscreencap=disabled \
		-Dwpe=disabled \
		-Dx265=disabled \
		-Dzbar=disabled \
		-Dyadif=disabled \
		-Dintrospection=disabled \
		-Dvulkan=disabled \
		-Ddtls=disabled \
		-Dwayland=enabled && \
	ninja -j $(JOBS) -C build install && \
	$(call fbprint_d,"gst_plugins_bad")
endif
endif
