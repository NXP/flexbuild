# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# GStreamer plugins 'bad' and helper libraries
# https://gstreamer.freedesktop.org

# depends on libsbc-dev libsndfile1-dev libwebp-dev


gst_plugins_bad:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"gst_plugins_bad") && \
	 $(call repo-mngr,fetch,gst_plugins_bad,apps/multimedia) && \
	 cd $(MMDIR)/gst_plugins_bad && \
	 if ! grep -q libexecdir= meson.build; then \
	     sed -i "/pkgconfig_variables =/a\  'libexecdir=\$\{prefix\}/libexec'," meson.build && \
	     sed -i "/pkgconfig_variables =/a\  'datadir=\$\{prefix\}/share'," meson.build && \
	     sed -i 's/0.62/0.61/' meson.build; \
	 fi && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/misc/meson/meson.cross > meson.cross && \
	 if [ ! -f $(DESTDIR)/usr/lib/gstreamer-1.0/libgstopengl.so ]; then \
	     bld gst_plugins_base -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/wayland-client.h ]; then \
	     bld wayland -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/share/pkgconfig/wayland-protocols.pc ]; then \
	     bld wayland_protocols -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 if [ -f $(RFSDIR)/usr/lib/aarch64-linux-gnu/libgstvideo-1.0.so.0 ]; then \
	     sudo rm -f $(RFSDIR)/lib/aarch64-linux-gnu/{libgstbase-1.0.so,libgstbase-1.0.so.0} && \
	     sudo rm -f $(RFSDIR)/lib/aarch64-linux-gnu/{libgstallocators-1.0.so,libgstsdp-1.0.so.0} && \
	     sudo rm -f $(RFSDIR)/lib/aarch64-linux-gnu/{libgstvideo-1.0.so.0,libgstaudio-1.0.so.0}; \
	 fi && \
	 sudo cp -rf $(DESTDIR)/usr/include/libdrm $(RFSDIR)/usr/include && \
	 sudo cp -rf $(DESTDIR)/usr/share/wayland-protocols $(RFSDIR)/usr/share && \
	 sudo cp -rf $(DESTDIR)/usr/include/gstreamer-1.0 $(RFSDIR)/usr/include && \
	 \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
		-Dc_args="-O2 -pipe -g -feliminate-unused-debug-types \
			  -I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/lib/gstreamer-1.0/include \
			  -I$(DESTDIR)/usr/include/gstreamer-1.0 -I$(RFSDIR)/usr/include" \
		-Dc_link_args="-Wl,-rpath-link=$(DESTDIR)/usr/lib -L$(DESTDIR)/usr/lib \
				-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -ludev -lbsd -lpthread -lgstbase-1.0" \
		-Dcpp_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu \
				 -ludev -lbsd -lpthread -lgstbase-1.0" \
		--prefix=/usr --buildtype=release \
		--cross-file meson.cross \
		--strip \
		-Dintrospection=disabled \
		-Dexamples=disabled \
		-Dnls=enabled \
		-Dgpl=disabled \
		-Ddoc=disabled \
		-Daes=enabled \
		-Dcodecalpha=enabled \
		-Ddecklink=enabled \
		-Ddvb=enabled \
		-Dfbdev=enabled \
		-Dipcpipeline=enabled \
		-Dshm=enabled \
		-Dtranscode=enabled \
		-Dandroidmedia=disabled \
		-Dapplemedia=disabled \
		-Dasio=disabled \
		-Dbs2b=disabled \
		-Dchromaprint=disabled \
		-Dd3dvideosink=disabled \
		-Dd3d11=disabled \
		-Ddirectsound=disabled \
		-Ddts=disabled \
		-Dfdkaac=disabled \
		-Dflite=disabled \
		-Dgme=disabled \
		-Dgs=disabled \
		-Dgsm=disabled \
		-Diqa=disabled \
		-Dkate=disabled \
		-Dladspa=disabled \
		-Dldac=disabled \
		-Dlv2=disabled \
		-Dmagicleap=disabled \
		-Dmediafoundation=disabled \
		-Dmicrodns=disabled \
		-Dmpeg2enc=disabled \
		-Dmplex=disabled \
		-Dmusepack=disabled \
		-Dnvcodec=disabled \
		-Dopenexr=disabled \
		-Dopenni2=disabled \
		-Dopenaptx=disabled \
		-Dopensles=disabled \
		-Donnx=disabled \
		-Dqroverlay=disabled \
		-Dspandsp=disabled \
		-Dsvthevcenc=disabled \
		-Dteletext=disabled \
		-Dwasapi=disabled \
		-Dwasapi2=disabled \
		-Dwildmidi=disabled \
		-Dwinks=disabled \
		-Dwinscreencap=disabled \
		-Dwpe=disabled \
		-Dzxing=disabled \
		\
		-Daom=disabled \
		-Dassrender=disabled \
		-Davtp=disabled \
		-Dbluez=enabled \
		-Dbz2=enabled \
		-Dclosedcaption=enabled \
		-Dcurl=enabled \
		-Ddash=enabled \
		-Ddc1394=disabled \
		-Ddirectfb=disabled \
		-Ddtls=disabled \
		-Dfaac=disabled \
		-Dfaad=disabled \
		-Dfluidsynth=disabled \
		-Dgl=enabled \
		-Dhls=enabled \
		-Dkms=enabled \
		-Dcolormanagement=disabled \
		-Dlibde265=disabled \
		-Dcurl-ssh2=disabled \
		-Dmodplug=disabled \
		-Dmsdk=disabled \
		-Dneon=disabled \
		-Dopenal=disabled \
		-Dopencv=disabled \
		-Dopenh264=disabled \
		-Dopenjpeg=disabled \
		-Dopenmpt=disabled \
		-Dhls-crypto=openssl \
		-Dopus=disabled \
		-Dorc=enabled \
		-Dresindvd=disabled \
		-Drsvg=enabled \
		-Drtmp=disabled \
		-Dsbc=enabled \
		-Dsctp=disabled \
		-Dsmoothstreaming=enabled \
		-Dsndfile=enabled \
		-Dsrt=disabled \
		-Dsrtp=disabled \
		-Dtinyalsa=disabled \
		-Dtinycompress=enabled \
		-Dttml=enabled \
		-Duvch264=enabled \
		-Dv4l2codecs=disabled \
		-Dva=disabled \
		-Dvoaacenc=disabled \
		-Dvoamrwbenc=disabled \
		-Dvulkan=disabled \
		-Dwayland=enabled \
		-Dwebp=enabled \
		-Dwebrtc=disabled \
		-Dwebrtcdsp=disabled \
		-Dx11=enabled \
		-Dx265=disabled \
		-Dzbar=disabled && \
	ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	$(call fbprint_d,"gst_plugins_bad")
