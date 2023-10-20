# Copyright 2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# NXP Asynchronous Sample Rate Converter



imx_dspc_asrc:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = base -o $(DISTROVARIANT) = tiny ] && exit || \
	 $(call fbprint_b,"imx_dspc_asrc") && \
	 cd $(MMDIR) && \
	 if [ ! -d imx_dspc_asrc ]; then \
	     wget -q $(repo_imx_dspc_asrc_bin_url) -O imx_dspc_asrc.bin && \
	     chmod +x imx_dspc_asrc.bin && ./imx_dspc_asrc.bin --auto-accept && \
	     mv imx-dspc-asrc* imx_dspc_asrc && rm -f imx_dspc_asrc.bin; \
	 fi && \
	 cd imx_dspc_asrc && \
	 ./configure CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" \
	   --enable-armv8 \
	   --libdir=/usr/lib \
	   --bindir=/unit_tests \
	   --prefix=/usr && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"imx_dspc_asrc")
