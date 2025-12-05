# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# G2D library using i.MX PXP on imx93



imx_pxp_g2d:
	@[ $${MACHINE:0:5} != imx93 -a $${MACHINE:0:5} != imx91 ] && exit || \
	 $(call download_repo,imx_pxp_g2d,apps/graphics) && \
	 $(call patch_apply,imx_pxp_g2d,apps/graphics) && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/pxp_device.h ]; then \
	     bld linux-headers -m $(MACHINE); \
	 fi && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)" && \
	 $(call fbprint_b,"imx_pxp_g2d") && \
	 cd $(GRAPHICSDIR)/imx_pxp_g2d && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) PLATFORM=IMX93 INCLUDE='-I$(DESTDIR)/usr/include' DEST_DIR=$(DESTDIR) $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS)  DEST_DIR=$(DESTDIR) install $(LOG_MUTE) && \
	 $(call fbprint_d,"imx_pxp_g2d")
