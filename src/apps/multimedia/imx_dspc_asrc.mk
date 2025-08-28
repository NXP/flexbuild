# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP Asynchronous Sample Rate Converter



imx_dspc_asrc:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_dspc_asrc") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_dspc_asrc ]; then \
		 rm -rf imx_dspc_asrc*; \
	     $(WGET) $(repo_imx_dspc_asrc_bin_url) -O imx_dspc_asrc.bin $(LOG_MUTE); \
		 [ $$? -ne 0 ] && { echo "Downloading $(repo_imx_dspc_asrc_bin_url) failed."; exit 1; } || \
	     chmod +x imx_dspc_asrc.bin && ./imx_dspc_asrc.bin --auto-accept --force $(LOG_MUTE); \
	     mv imx-dspc-asrc* imx_dspc_asrc && rm -f imx_dspc_asrc.bin; \
	 fi && \
	 cd imx_dspc_asrc && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --enable-armv8 \
	   --libdir=/usr/lib \
	   --bindir=/unit_tests \
	   --prefix=/usr $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_dspc_asrc")
