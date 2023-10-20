# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# i.MX DSP Wrapper, Firmware Binary, Codec Libraries for mx8mp, mx8qm, mx8qxp, mx8dx, mx8ulp


ifeq ($(MACHINE),all)
  HIFI4_PLATFORM = imx8mp
else ifeq ($(MACHINE),imx8mpevk)
  HIFI4_PLATFORM = imx8mp
else ifeq ($(MACHINE),imx8ulpevk)
  HIFI4_PLATFORM = imx8ulp
else
  HIFI4_PLATFORM = imx8qmqxp
endif


imx_dsp:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_dsp") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_dsp ]; then \
	     wget -q $(repo_imx_dsp_bin_url) -O imx_dsp.bin && \
	     chmod +x imx_dsp.bin && ./imx_dsp.bin --auto-accept && \
	     mv imx-dsp* imx_dsp && rm -f imx_dsp.bin; \
	 fi && \
	 cd imx_dsp && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --bindir=/unit_tests \
	   -datadir=/lib/firmware \
	   --enable-armv8 \
	   --prefix=/usr && \
	 export DESTDIR=$(FBOUTDIR)/bsp/imx_firmware && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 ln -sf hifi4_$(HIFI4_PLATFORM).bin $(FBOUTDIR)/bsp/imx_firmware/lib/firmware/imx/dsp/hifi4.bin && \
	 $(call fbprint_d,"imx_dsp")
