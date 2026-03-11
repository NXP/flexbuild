# Copyright 2023-2024,2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# G2D library using i.MX PXP on imx93



imx_pxp_g2d: $(KHEADER_FILE)
	@$(call download_repo,imx_pxp_g2d,apps/graphics)
	 $(call patch_apply,imx_pxp_g2d,apps/graphics)
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 $(call fbprint_b,"imx_pxp_g2d")
	 cd $(GRAPHICSDIR)/imx_pxp_g2d
	 $(MAKE) clean $(LOG_MUTE)
	 $(MAKE) PLATFORM=IMX93 INCLUDE='-I$(DESTDIR)/usr/include' DEST_DIR=$(DESTDIR) $(LOG_MUTE)
	 $(MAKE)  DEST_DIR=$(DESTDIR) install $(LOG_MUTE)
	 $(call fbprint_d,"imx_pxp_g2d")
