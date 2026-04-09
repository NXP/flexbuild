# Copyright 2023,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX DSP Codec Wrapper and Lib for mx8mp, mx8qm, mx8qxp, mx8dx, mx8ulp


ifeq ($(CONFIG_SOC_IMX8M),y)
  EXTRA_CONF = --enable-imx8m
else ifeq ($(CONFIG_SOC_IMX8QMMEK),y)
  EXTRA_CONF = --enable-imx8qmqxp
else
  EXTRA_CONF =
endif


imx_dsp_codec_ext:
	@$(call dl_by_wget,imx_dsp_codec_ext_bin,imx_dsp_codec_ext.bin)
	cd $(MMDIR)
	if [ ! -d "$(MMDIR)"/imx_dsp_codec_ext ]; then
		chmod +x $(FBDIR)/dl/imx_dsp_codec_ext.bin
		$(FBDIR)/dl/imx_dsp_codec_ext.bin --auto-accept --force $(LOG_MUTE)
		mv imx-dsp-codec-ext* imx_dsp_codec_ext
	fi
	$(call fbprint_b,"imx_dsp_codec_ext")
	cd imx_dsp_codec_ext
	./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   $(EXTRA_CONF) \
	   --prefix=/usr $(LOG_MUTE)
	$(MAKE) $(LOG_MUTE)
	$(MAKE) install $(LOG_MUTE)
	$(call fbprint_d,"imx_dsp_codec_ext")
