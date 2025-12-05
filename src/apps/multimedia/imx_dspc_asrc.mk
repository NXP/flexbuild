# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP Asynchronous Sample Rate Converter



imx_dspc_asrc:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	$(call dl_by_wget,imx_dspc_asrc_bin,imx_dspc_asrc.bin) && \
	cd $(MMDIR) && \
	if [ ! -d "$(MMDIR)"/imx_dspc_asrc ]; then \
		chmod +x $(FBDIR)/dl/imx_dspc_asrc.bin; \
		$(FBDIR)/dl/imx_dspc_asrc.bin --auto-accept --force $(LOG_MUTE); \
		mv imx-dspc-asrc* imx_dspc_asrc; \
	fi && \
	$(call fbprint_b,"imx_dspc_asrc") && \
	cd imx_dspc_asrc && \
	./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --enable-armv8 \
	   --libdir=/usr/lib \
	   --bindir=/unit_tests \
	   --prefix=/usr $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	$(MAKE) install $(LOG_MUTE) && \
	$(call fbprint_d,"imx_dspc_asrc")
