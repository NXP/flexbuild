# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP PDM to PCM Software Decimation SIMD Library


imx_sw_pdm:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_sw_pdm") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_sw_pdm ]; then \
	     wget -q $(repo_imx_sw_pdm_bin_url) -O imx_sw_pdm.bin && \
	     chmod +x imx_sw_pdm.bin && ./imx_sw_pdm.bin --auto-accept && \
	     mv imx-sw-pdm* imx_sw_pdm && rm -f imx_sw_pdm.bin; \
	 fi && \
	 cd imx_sw_pdm && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_sw_pdm")
