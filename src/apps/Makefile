
#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK Application Components
#


# ============================================================================
# Main apps target - aggregate all enabled modules
# ============================================================================



GRAPHICSDIR = $(PKGDIR)/apps/graphics
MMDIR = $(PKGDIR)/apps/multimedia
NETDIR = $(PKGDIR)/apps/networking
SECDIR = $(PKGDIR)/apps/security
UTILSDIR = $(PKGDIR)/apps/utils
MLDIR = $(PKGDIR)/apps/ml
GPDIR = $(PKGDIR)/apps/gopoint
ROBOTDIR = $(PKGDIR)/apps/robotics


include src/apps/graphics/Makefile
include src/apps/multimedia/Makefile
include src/apps/networking/Makefile
include src/apps/ml/Makefile
include src/apps/gopoint/Makefile
include src/apps/security/Makefile
include src/apps/utils/Makefile
include src/apps/robotics/Makefile


ALL_APPS := $(APPS_GFX) $(APPS_MM) $(APPS_GP) $(APPS_UTILS) $(APPS_ML) $(APPS_SEC) $(APPS_NET) $(APPS_ROTOTICS)
ALL_MODULES := $(GP_MODULES) $(GFX_MODULES) $(ML_MODULES) $(MM_MODULES) $(NET_MODULES) $(ROBOTICS_MODULES) $(SEC_MODULES) $(UTILS_MODULES)

ALL_MODULES: $(KHEADER_FILE) $(KERNEL_IMAGE) $(RFS_FILE)
.PHONY: apps
apps: multimedia graphics networking security ml gopoint utils robotics
	@$(call fbprint_d,"apps components")
