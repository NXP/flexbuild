# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Gstreamer iMX lib 

imx_lib:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_lib") && \
	 $(call repo-mngr,fetch,imx_lib,apps/multimedia) && \
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
