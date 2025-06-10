# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia parser libs


imx_parser:
	@[ $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_parser") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_parser ]; then \
	     wget -q $(repo_imx_parser_bin_url) -O imx_parser.bin $(LOG_MUTE) && \
	     chmod +x imx_parser.bin && ./imx_parser.bin --auto-accept $(LOG_MUTE) && \
	     mv imx-parser* imx_parser && rm -f imx_parser.bin; \
	 fi && \
	 cd imx_parser && \
	 ./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --disable-static \
	   --prefix=/usr $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_parser")
