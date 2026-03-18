# Copyright 2025-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Gstreamer iMX lib 

imx_lib: $(KHEADER_FILE)
	@$(call download_repo,imx_lib,apps/multimedia)
	 $(call patch_apply,imx_lib,apps/multimedia)
	 $(call fbprint_b,"imx_lib")
	 cd $(MMDIR)/imx_lib
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR)"
	 export AR="$(CROSS_COMPILE)ar"
	 export CFLAGS="-O2 -I$(DESTDIR)/usr/include"
	 $(MAKE) clean $(LOG_MUTE)
	 # to enable PXP, IMX8ULP must be assigned
	 PLATFORM=IMX8ULP $(MAKE) all $(LOG_MUTE)
	 $(MAKE) install DEST_DIR=$(DESTDIR) $(LOG_MUTE)
	 $(call fbprint_d,"imx_lib")
