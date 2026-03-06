#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#


# ============================================================================
# Define all possible GoPoint demo modules
# ============================================================================
GP_MODULES := \
    gtec_demo_framework \
    imx_demo_experience \
    imx_demos_list \
    imx_ebike_vit \
    imx_ele \
    imx_nnstreamer_examples \
    imx_smart_fitness \
    imx_smart_kitchen \
    imx_video2texture \
    imx_voiceplayer \
    imx_voiceui \
    nxp_afe \
    imx_camera_rotation \
    nxp_demo_experience_assets

# ============================================================================
# Automatically include enabled modules and build APPS_GP
# ============================================================================
APPS_GP :=

$(foreach m,$(GP_MODULES), \
    $(eval _cfg := CONFIG_GP_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/gopoint/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_GP += $(m))) \
)

# ============================================================================
# GoPoint target using APPS_GP
# ============================================================================
.PHONY: gopoint
gopoint: $(APPS_GP)


