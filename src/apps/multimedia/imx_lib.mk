# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Gstreamer iMX lib 

imx_lib:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	 $(call download_repo,imx_lib,apps/multimedia) && \
	 $(call patch_apply,imx_lib,apps/multimedia) && \
	 $(call fbprint_b,"imx_lib") && \
	 cd $(MMDIR)/imx_lib && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 export AR="$(CROSS_COMPILE)ar" && \
	 export CFLAGS="-O2 -I$(DESTDIR)/usr/include" && \
	 \
	 if [ "$${MACHINE:0:4}" = "imx9" ]; then \
             SOCPLATFORM="MX9"; \
         else \
             SOCPLATFORM="MX8"; \
         fi && \
	 $(MAKE) clean && \
     # to enable PXP, IMX8ULP must be assigned && \
	 PLATFORM=IMX8ULP $(MAKE) -j$(JOBS) all $(LOG_MUTE) && \
	 #PLATFORM=$${SOCPLATFORM} $(MAKE) -j$(JOBS) all && \
	 $(MAKE) install DEST_DIR=$(DESTDIR) $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_lib")
