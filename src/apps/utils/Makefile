#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#


# ============================================================================
# Define all possible utility modules
# ============================================================================
UTILS_MODULES := \
    firmwared \
    firmware_imx \
    imx_firmware \
    imx_test \
    mcore_demo \
    wireless_regdb \
    perf

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_UTILS-y :=

# Add modules based on CONFIG_UTILS_* settings
APPS_UTILS-$(CONFIG_UTILS_FIRMWARED) += firmwared
APPS_UTILS-$(CONFIG_UTILS_FIRMWARE_IMX) += firmware_imx
APPS_UTILS-$(CONFIG_UTILS_IMX_FIRMWARE) += imx_firmware
APPS_UTILS-$(CONFIG_UTILS_IMX_TEST) += imx_test
APPS_UTILS-$(CONFIG_UTILS_MCORE_DEMO) += mcore_demo
APPS_UTILS-$(CONFIG_UTILS_WIRELESS_REGDB) += wireless_regdb
APPS_UTILS-$(CONFIG_UTILS_PERF) += perf

# Create alias for backward compatibility
APPS_UTILS := $(APPS_UTILS-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_UTILS-y), \
    $(eval include $(FBDIR)/src/apps/utils/$(m).mk))

# ============================================================================
# Utility target using APPS_UTILS-y
# ============================================================================
.PHONY: utils
utils: $(APPS_UTILS-y)
