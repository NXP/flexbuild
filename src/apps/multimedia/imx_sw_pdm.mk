# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP PDM to PCM Software Decimation SIMD Library


imx_sw_pdm:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"imx_sw_pdm") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_sw_pdm ]; then \
		 rm -rf imx_sw_pdm*; \
	     $(WGET) $(repo_imx_sw_pdm_bin_url) -O imx_sw_pdm.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_imx_sw_pdm_bin_url) failed."; exit 1; } || \
	     chmod +x imx_sw_pdm.bin && ./imx_sw_pdm.bin --auto-accept --force $(LOG_MUTE); \
	     mv imx-sw-pdm* imx_sw_pdm && rm -f imx_sw_pdm.bin; \
	 fi && \
	 cd imx_sw_pdm && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --prefix=/usr $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_sw_pdm")
