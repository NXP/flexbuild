# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# UUU (Universal Update Utility) mfgtools

# https://github.com/nxp-imx/mfgtools


uuu:
ifeq ($(CONFIG_UUU),y)
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call fbprint_b,"UUU") && \
	 $(call repo-mngr,fetch,uuu,apps/utils) && \
	 cd $(UTILSDIR)/uuu && \
	 export CC=gcc && export CXX=g++ && \
	 export LD_LIBRARY_PATH=/usr/lib:/usr/lib/x86_64-linux-gnu && \
	 export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig && \
	 export PKG_CONFIG_SYSROOT_DIR="" && \
	 cmake -Wno-dev . && \
	 $(MAKE) -j$(JOBS) && \
	 install uuu/uuu $(FBDIR) && \
	 install uuu/uuu $(FBOUTDIR)/images && \
	 $(call fbprint_d,"UUU")
endif
