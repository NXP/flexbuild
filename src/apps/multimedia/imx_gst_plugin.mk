# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Gstreamer iMX plugins

# depends on imx-codec imx-parser libdrm gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad

ifeq ($${MACHINE:0:4},imx9)
  SOCPLATFORM = MX9
else
  SOCPLATFORM = MX8
endif



imx_gst_plugin:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_gst_plugin") && \
	 $(call repo-mngr,fetch,imx_gst_plugin,apps/multimedia) && \
	 cd $(MMDIR)/imx_gst_plugin && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_SYSROOT_DIR="" && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 sed -i "s/libfslaudiocodec', required: false/libfslaudiocodec', required: true/"  plugins/meson.build && \
	 if [ ! -d $(DESTDIR)/usr/include/libdrm ]; then \
	     bld libdrm -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/pkgconfig/imx-parser.pc ]; then \
	     bld imx_parser -r $(DISTROTYPE):$(DISTROVARIANT); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libgstplay-1.0.so.0 ]; then \
	     bld gst_plugins_bad -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/include/hantro_VC8000E_enc/hevcencapi.h ]; then \
	     bld imx_vpu_hantro_vc -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/libfslvpuwrap.so ]; then \
	     bld imx_vpuwrap -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(DESTDIR)/usr/lib/pkgconfig/libfslaudiocodec.pc ]; then \
	     bld imx_codec -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH); \
	 fi && \
	 if [ ! -f $(RFSDIR)/usr/include/imx-mm/audio-codec/fsl_unia.h ]; then \
	     sudo cp -rf $(DESTDIR)/usr/include/imx-mm $(RFSDIR)/usr/include; \
	 fi && \
	 \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
	      -Dc_args="-O2 -pipe -g -feliminate-unused-debug-types -Wno-unused-variable -Wno-format -Wno-unused-value \
			-Wno-unused-function -Wno-error=nonnull -Wno-error=implicit-function-declaration \
			-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/gstreamer-1.0" \
	      -Dc_link_args="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" \
	      --prefix=/usr --buildtype=release \
	      --cross-file meson.cross \
	      -Dplatform=$(SOCPLATFORM) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install && \
	 sed -i 's|$(RFSDIR)||g' $(DESTDIR)/usr/share/beep_registry_1.0.arm.cf && \
	 $(call fbprint_d,"imx_gst_plugin")
