# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX DSP Codec Wrapper and Lib for mx8mp, mx8qm, mx8qxp, mx8dx, mx8ulp


ifeq ($(MACHINE),all)
  EXTRA_CONF = --enable-imx8m
else ifeq ($(MACHINE),imx8mpevk)
  EXTRA_CONF = --enable-imx8m
else ifeq ($(MACHINE),imx8ulpevk)
  EXTRA_CONF = --enable-imx8ulp
else ifeq ($(MACHINE),imx8qxpmek)
  EXTRA_CONF = --enable-imx8qmqxp
else ifeq ($(MACHINE),imx8qmmek)
  EXTRA_CONF = --enable-imx8qmqxp
else
  EXTRA_CONF =
endif


imx_dsp_codec_ext:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_dsp_codec_ext $(EXTRA_CONF)") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_dsp_codec_ext ]; then \
	     wget -q $(repo_imx_dsp_codec_ext_bin_url) -O imx_dsp_codec_ext.bin && \
	     chmod +x imx_dsp_codec_ext.bin && ./imx_dsp_codec_ext.bin --auto-accept && \
	     mv imx-dsp-codec-ext* imx_dsp_codec_ext && rm -f imx_dsp_codec_ext.bin; \
	 fi && \
	 cd imx_dsp_codec_ext && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   $(EXTRA_CONF) \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_dsp_codec_ext")
