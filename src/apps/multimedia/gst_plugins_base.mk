# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# 'base' GStreamer plugins and helper libraries
# https://gstreamer.freedesktop.org

# need to set gl_winsys with x11 to include libX11-xcb.so libX11.so for libgstgl-1.0.so

# gst version 1.24.0

gst_plugins_base: gpu_viv libdrm gstreamer imx_gpu_g2d alsa_lib wayland_protocols
	@[ $(SOCFAMILY) != IMX -a $${MACHINE:0:7} != ls1028a -o \
	   $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call repo-mngr,fetch,gst_plugins_base,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_base && \
	 mkdir -p $(DESTDIR)/usr/lib/pkgconfig && \
	 if [ ! -f .patchdone ] && [ $${MACHINE:0:6} = imx8qm -o $${MACHINE:0:7} = imx8qxp ]; then \
	     git am $(FBDIR)/patch/gst_plugins_base/*g2d-into-playsink.patch $(LOG_MUTE) && touch .patchdone; \
	 fi && \
	 if ! grep -q libexecdir= meson.build; then \
	     sed -i "/pkgconfig_variables =/a\  'libexecdir=\$\{prefix\}/libexec'," meson.build && \
	     sed -i "/pkgconfig_variables =/a\  'datadir=\$\{prefix\}/share'," meson.build && \
	     sed -i 's/1\.1/0.61/' meson.build; \
	 fi && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -d $(RFSDIR)/usr/lib/aarch64-linux-gnu ]; then \
	     bld rfs -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgbm_viv.so ]; then \
	     bld gpu_viv -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/libdrm ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -d $(DESTDIR)/usr/include/gstreamer-1.0 ]; then \
	     bld gstreamer -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libg2d.so ]; then \
	      bld imx_gpu_g2d -m imx8mmevk -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/dma-buf.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if  [ ! -f $(DESTDIR)/usr/include/alsa/asoundlib.h ]; then \
	     bld alsa_lib -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/include/gstreamer-1.0/gst/gstbytearrayinterface.h ]; then \
	     sudo cp -Prf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include; \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/share/pkgconfig/wayland-protocols.pc ]; then \
	      bld wayland_protocols -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 $(call fbprint_b,"gst_plugins_base") && \
	 sudo cp -rf $(DESTDIR)/usr/share/{pkgconfig,wayland-protocols} $(RFSDIR)/usr/share/ && \
	 sudo cp -fPa $(DESTDIR)/usr/lib/{libGAL.so,libdrm.so*,libdrm_vivante.so*,libg2d*.so*} $(RFSDIR)/usr/lib && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgstbase-1.0.so.0,libgstaudio-1.0.so.0,libgstvideo-1.0.so.0,libgsttag-1.0.so.0,libgstpbutils-1.0.so.0} && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgstallocators-1.0.so.0,libgstreamer-1.0.so.0,libdrm.so.2} && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export GI_SCANNER_DISABLE_CACHE=1 && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file meson.cross \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/gstreamer-1.0" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(DESTDIR)/usr/lib/gstreamer-1.0 \
			       -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -lgbm -lEGL \
			       -lgbm_viv -lgstbase-1.0 -lgstreamer-1.0 -lpthread -ldl" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(DESTDIR)/usr/lib/gstreamer-1.0 -L$(RFSDIR)/usr/lib/aarch64-linux-gnu \
			       -lgbm -lEGL -lgbm_viv -lgstbase-1.0 -lgstreamer-1.0 -lpthread -ldl" \
		--prefix=/usr --buildtype=release \
		--strip \
		-Dintrospection=disabled \
		-Dexamples=disabled \
		-Dnls=enabled \
		-Ddoc=disabled \
		-Dgl_api=gles2 \
		-Dgl_platform=egl \
		-Dgl_winsys=egl,viv-fb,wayland,x11 \
		-Dalsa=enabled \
		-Dcdparanoia=disabled \
		-Dgl-graphene=disabled \
		-Dgl-jpeg=disabled \
		-Dogg=enabled \
		-Dopus=disabled \
		-Dorc=enabled \
		-Dpango=enabled \
		-Dgl-png=enabled \
		-Dqt5=disabled \
		-Dtheora=enabled \
		-Dtremor=disabled \
		-Dlibvisual=disabled \
		-Dvorbis=enabled \
		-Dx11=enabled \
		-Dxvideo=enabled \
		-Dxshm=enabled $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 $(call fbprint_d,"gst_plugins_base")
