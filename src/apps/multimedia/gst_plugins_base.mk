# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause




gst_plugins_base:
ifeq ($(CONFIG_GSTREAMER), "y")
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || \
	 $(call fbprint_b,"gst_plugins_base") && \
	 $(call repo-mngr,fetch,gst_plugins_base,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_base && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_PATH=$(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@TARGET_ARCH@%aarch64%g' \
	     -e 's%@TARGET_CPU@%cortex-a53%g' -e 's%@TARGET_ENDIAN@%little%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     $(FBDIR)/src/misc/meson/cross-compilation.conf > cross-compilation.conf && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld -i mkrfs -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgbm_viv.so ]; then \
	     bld -c gpulib -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML) && \
	     sudo cp -rf $(DESTDIR)/usr/lib/lib* $(RFSDIR)/usr/lib/; \
	 fi && \
	 if [ ! -d $(RFSDIR)/usr/include/libdrm ]; then \
	     bld -c libdrm -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/gstreamer-1.0 ]; then \
	     bld -c gstreamer -r $(DISTROTYPE):$(DISTROSCALE) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/imx/linux/dma-buf.h ]; then \
	     bld -c imx_vpu -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libg2d.so ]; then \
              bld -c imx_g2d -r $(DISTROTYPE):$(DISTROSCALE) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/lib/libgstbase-1.0.so ]; then \
	     sudo cp -rf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include && \
	     sudo cp -rf $(DESTDIR)/usr/lib/libgst* $(DESTDIR)/usr/lib/libGAL.so $(DESTDIR)/usr/lib/libgbm_viv.so* \
	          $(DESTDIR)/usr/lib/libg2d*.so* $(RFSDIR)/usr/lib && \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstbase-1.0.so && \
	     sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstreamer-1.0.so; \
	 fi && \
	 mkdir -p build && \
	 meson build \
	      -Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/imx -I$(RFSDIR)/usr/include/gstreamer-1.0" \
	      -Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib -lgbm -lEGL -lgbm_viv -lgstbase-1.0 -lgstreamer-1.0 -lpthread -ldl" \
	      --prefix=/usr --buildtype=release --cross-file cross-compilation.conf \
	      -Dgl-graphene=disabled \
	      -Dalsa=enabled && \
	 ninja -j $(JOBS) -C build install && \
	 $(call fbprint_d,"gst_plugins_base")
endif
endif
