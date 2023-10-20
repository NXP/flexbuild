# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# G2D library using i.MX PXP on imx93



imx_pxp_g2d:
	@[ $(DESTARCH) != arm64 -o $(DISTROVARIANT) != desktop ] && exit || \
	 $(call fbprint_b,"imx_pxp_g2d") && \
	 $(call repo-mngr,fetch,imx_pxp_g2d,apps/graphics) && \
	 if [ ! -f $(DESTDIR)/usr/include/linux/pxp_device.h ]; then \
	     bld linux-headers -r $(DISTROTYPE):$(DISTROVARIANT) -a $(DESTARCH) -f $(CFGLISTYML); \
	 fi && \
	 cd $(GRAPHICSDIR)/imx_pxp_g2d && \
	 \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) PLATFORM=IMX93 INCLUDE='-I$(DESTDIR)/usr/include' DEST_DIR=$(DESTDIR) && \
	 $(MAKE) -j$(JOBS)  DEST_DIR=$(DESTDIR) install && \
	 rm -f $(DESTDIR)/usr/lib/libg2d.so.2 && \
	 $(call fbprint_d,"imx_pxp_g2d")
