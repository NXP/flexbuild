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
	@[ $${MACHINE:0:4} != imx8  ] && exit || \
	$(call dl_by_wget,imx_dsp_bin,imx_dsp.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_dsp ]; then \
		chmod +x $(FBDIR)/dl/imx_dsp.bin; \
		$(FBDIR)/dl/imx_dsp.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-dsp* imx_dsp; \
	fi && \
	$(call fbprint_b,"imx_dsp") && \
	cd "$(MMDIR)"/imx_dsp && \
	./configure CC=aarch64-linux-gnu-gcc \
	   --bindir=/unit_tests \
	   -datadir=/lib/firmware \
	   --enable-armv8 \
	   --prefix=/usr $(LOG_MUTE) && \
	export DESTDIR=$(DESTDIR) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install $(LOG_MUTE) && \
	ln -sf hifi4_$(HIFI4_PLATFORM).bin $(DESTDIR)/lib/firmware/imx/dsp/hifi4.bin && \
	$(call fbprint_d,"imx_dsp")
