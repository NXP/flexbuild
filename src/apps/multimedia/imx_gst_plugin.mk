# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Gstreamer iMX plugins

# depends on imx-codec imx-parser libdrm gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad

imx_gst_plugin: libdrm imx_parser gst_plugins_bad imx_vpu_hantro_vc imx_vpuwrap imx_codec
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call repo-mngr,fetch,imx_gst_plugin,apps/multimedia) && \
	 cd $(MMDIR)/imx_gst_plugin && \
	 if [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/imx_gst_plugin/*.patch $(LOG_MUTE) && touch .patchdone; \
	 fi && \
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
	 $(call fbprint_b,"imx_gst_plugin") && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
	      -Dc_args="-O2 -pipe -g -feliminate-unused-debug-types -Wno-unused-variable -Wno-format -Wno-unused-value \
			-Wno-unused-function -Wno-error=nonnull -Wno-error=implicit-function-declaration -DNO_G2D=1 \
			-I$(DESTDIR)/usr/include -I$(RFSDIR)/usr/include/gstreamer-1.0" \
	      -Dc_link_args="-L$(RFSDIR)/usr/lib/aarch64-linux-gnu -L$(DESTDIR)/usr/lib  -lasound " \
	      --prefix=/usr --buildtype=release \
	      --cross-file meson.cross \
	      -Dplatform=$(shell if [ "$${MACHINE:0:4}" = "imx9" ]; then echo "MX9"; else echo "MX8"; fi) $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 sed -i 's|$(RFSDIR)||g' $(DESTDIR)/usr/share/beep_registry_1.0.arm.cf && \
	 $(call fbprint_d,"imx_gst_plugin")
