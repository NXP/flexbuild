# Copyright 2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia parser libs


imx_parser:
ifeq ($(DESTARCH),arm64)
	@[ $(DISTROTYPE) != ubuntu -o $(DISTROSCALE) != desktop ] && exit || true && \
	 $(call fbprint_b,"imx_parser") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_parser ]; then \
	     wget -q $(repo_imx_parser_bin_url) -O imx_parser.bin && \
	     chmod +x imx_parser.bin && ./imx_parser.bin --auto-accept && \
	     mv imx-parser* imx_parser && rm -f imx_parser.bin; \
	 fi && \
	 cd imx_parser && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --enable-fhw \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_parser")
endif
