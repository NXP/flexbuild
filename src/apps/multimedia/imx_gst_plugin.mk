# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Gstreamer iMX plugins

# depends on imx-codec imx-parser libdrm gstreamer1.0 gstreamer1.0-plugins-base gstreamer1.0-plugins-bad



ifeq ($(filter imx93%,$(MACHINE)),$(MACHINE))
	_GST_PLUGIN_PLAT = MX9
	DEP_GST_PLUGIN = imx_pxp_g2d
else ifeq ($(filter imx8%,$(MACHINE)),$(MACHINE))
	_GST_PLUGIN_PLAT = MX8
	DEP_GST_PLUGIN = imx_gpu_g2d imx_dpu_g2d_v1
else ifeq ($(filter imx95%,$(MACHINE)),$(MACHINE))
	_GST_PLUGIN_PLAT = MX9
	DEP_GST_PLUGIN = imx_dpu_g2d_v2
else
	_GST_PLUGIN_PLAT = MX9
	DEP_GST_PLUGIN = imx_pxp_g2d
endif

#imx_gst_plugin:
imx_gst_plugin: $(DEP_GST_PLUGIN) imx_lib libdrm imx_parser gst_plugins_bad imx_vpu_hantro_vc imx_vpuwrap imx_codec
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_gst_plugin,apps/multimedia) && \
	 $(call patch_apply,imx_gst_plugin,apps/multimedia) && \
	 cd $(MMDIR)/imx_gst_plugin && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export CROSS=$(CROSS_COMPILE) && \
	 export PKG_CONFIG_SYSROOT_DIR="" && \
	 sed -e 's%@TARGET_CROSS@%$(CROSS_COMPILE)%g' -e 's%@STAGING_DIR@%$(RFSDIR)%g' \
	     -e 's%@DESTDIR@%$(DESTDIR)%g' $(FBDIR)/src/system/meson.cross > meson.cross && \
	 sed -i "s/libfslaudiocodec', required: false/libfslaudiocodec', required: true/"  plugins/meson.build && \
	 if [ ! -f $(RFSDIR)/usr/include/imx-mm/audio-codec/fsl_unia.h ]; then \
	     sudo cp -rf $(DESTDIR)/usr/include/imx-mm $(RFSDIR)/usr/include; \
	 fi && \
	 cp -af $(DESTDIR)/usr/lib/libgstaudio-1.0.so* $(RFSDIR)/usr/lib/ && \
	 cp -af $(DESTDIR)/usr/lib/libgstpbutils-1.0.so* $(RFSDIR)/usr/lib/ && \
	 \
	 $(call fbprint_b,"imx_gst_plugin") && \
	 rm -rf build_$(DISTROTYPE)_$(ARCH) && \
	 meson setup build_$(DISTROTYPE)_$(ARCH) \
	      -Dc_args="-O2 -pipe -g -feliminate-unused-debug-types -Wno-unused-variable -Wno-format -Wno-unused-value \
			-Wno-unused-function -Wno-error=nonnull -Wno-error=implicit-function-declaration -DNO_G2D=1 \
			-I$(DESTDIR)/usr/include -I$(DESTDIR)/usr/include/gstreamer-1.0" \
	      -Dc_link_args="-L$(DESTDIR)/usr/lib/gstreamer-1.0 -L$(DESTDIR)/usr/lib -lgsttag-1.0 -lasound " \
	      --prefix=/usr --buildtype=release \
	      --cross-file meson.cross \
	      -Dplatform=$(_GST_PLUGIN_PLAT) $(LOG_MUTE) && \
	 ninja -j $(JOBS) -C build_$(DISTROTYPE)_$(ARCH) install $(LOG_MUTE) && \
	 sed -i 's|$(RFSDIR)||g' $(DESTDIR)/usr/share/beep_registry_1.0.arm.cf && \
	 $(call fbprint_d,"imx_gst_plugin")
