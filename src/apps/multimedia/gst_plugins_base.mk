# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# 'base' GStreamer plugins and helper libraries
# https://gstreamer.freedesktop.org

# need to set gl_winsys with x11 to include libX11-xcb.so libX11.so for libgstgl-1.0.so

# depends on: linux-headers


ifeq ($(filter imx95%,$(MACHINE)),$(MACHINE))
  DEP_GSTBASE = mali_imx imx_dpu_g2d_v2
else ifeq ($(filter imx8%,$(MACHINE)),$(MACHINE))
  DEP_GSTBASE = gpu_viv imx_gpu_g2d imx_dpu_g2d_v1
else
  DEP_GSTBASE =
endif

#gst_plugins_base:
gst_plugins_base: $(DEP_GSTBASE) libdrm gstreamer alsa_lib wayland_protocols
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,gst_plugins_base,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_base && \
	 mkdir -p $(DESTDIR)/usr/lib/pkgconfig && \
	 if ! grep -q libexecdir= meson.build; then \
	     sed -i "/pkgconfig_variables =/a\  'libexecdir=\$\{prefix\}/libexec'," meson.build && \
	     sed -i "/pkgconfig_variables =/a\  'datadir=\$\{prefix\}/share'," meson.build; \
	 fi && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/dma-buf.h ]; then \
		bld linux-headers -m $(MACHINE); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/include/gstreamer-1.0/gst/gstbytearrayinterface.h ]; then \
	     sudo cp -Prf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include; \
	 fi && \
	 $(call fbprint_b,"gst_plugins_base") && \
	 sudo cp -rf $(DESTDIR)/usr/share/{pkgconfig,wayland-protocols} $(RFSDIR)/usr/share/ && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgstbase-1.0.so.0,libgstaudio-1.0.so.0,libgstvideo-1.0.so.0,libgsttag-1.0.so.0,libgstpbutils-1.0.so.0} && \
	 sudo rm -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/{libgstallocators-1.0.so.0,libgstreamer-1.0.so.0,libdrm.so.2} && \
	 \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CXX="$(CROSS_COMPILE)g++ --sysroot=$(RFSDIR)" && \
	 export GI_SCANNER_DISABLE_CACHE=1 && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		--cross-file meson.cross \
		-Dc_args="-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/gstreamer-1.0" \
		-Dc_link_args="-L$(DESTDIR)/usr/lib -L$(DESTDIR)/usr/lib/gstreamer-1.0 \
			       -L$(RFSDIR)/usr/lib/aarch64-linux-gnu -Wl,-rpath-link=$(DESTDIR)/usr/lib \
			       -lEGL -lgstbase-1.0 -lgstreamer-1.0 -lpthread -ldl" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(DESTDIR)/usr/lib/gstreamer-1.0 -L$(RFSDIR)/usr/lib/aarch64-linux-gnu \
			       -lEGL -lgstbase-1.0 -lgstreamer-1.0 -lpthread -ldl -Wl,-rpath-link=$(DESTDIR)/usr/lib" \
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
	 cp -af $(DESTDIR)/usr/lib/libgstvideo-1.0.so* $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libgstpbutils-1.0.so* $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libgstaudio-1.0.so* $(RFSDIR)/usr/lib/ && \
	 $(call fbprint_d,"gst_plugins_base")
