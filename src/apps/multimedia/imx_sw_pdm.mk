# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP PDM to PCM Software Decimation SIMD Library


imx_sw_pdm:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,imx_sw_pdm_bin,imx_sw_pdm.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_sw_pdm ]; then \
		chmod +x $(FBDIR)/dl/imx_sw_pdm.bin; \
		$(FBDIR)/dl/imx_sw_pdm.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-sw-pdm* imx_sw_pdm; \
	fi && \
	$(call fbprint_b,"imx_sw_pdm") && \
	cd imx_sw_pdm && \
	./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --prefix=/usr $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install $(LOG_MUTE) && \
	$(call fbprint_d,"imx_sw_pdm")
