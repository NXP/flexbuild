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
# Automatically include enabled modules and build APPS_UTILS
# ============================================================================
APPS_UTILS :=

$(foreach m,$(UTILS_MODULES), \
    $(eval _cfg := CONFIG_UTILS_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/utils/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_UTILS += $(m))) \
)

# ============================================================================
# Utility target using APPS_UTILS
# ============================================================================
.PHONY: utils
utils: $(APPS_UTILS)

