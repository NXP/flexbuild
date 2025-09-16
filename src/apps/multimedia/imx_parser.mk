# Copyright 2021-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# iMX multimedia parser libs


imx_parser:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,imx_parser_bin,imx_parser.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_parser ]; then \
		chmod +x $(FBDIR)/dl/imx_parser.bin; \
		$(FBDIR)/dl/imx_parser.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-parser-* imx_parser; \
	fi && \
	$(call fbprint_b,"imx_parser") && \
	cd imx_parser && \
	./configure CC=aarch64-linux-gnu-gcc \
	   --enable-armv8 \
	   --disable-static \
	   --prefix=/usr $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install $(LOG_MUTE) && \
	$(call fbprint_d,"imx_parser")
