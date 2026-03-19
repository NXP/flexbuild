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
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_GP-y :=
GPNT_APPS_FOLDER := /opt/gopoint-apps

# Add modules based on CONFIG_GP_* settings
APPS_GP-$(CONFIG_GP_GTEC_DEMO_FRAMEWORK) += gtec_demo_framework
APPS_GP-$(CONFIG_GP_IMX_DEMO_EXPERIENCE) += imx_demo_experience
APPS_GP-$(CONFIG_GP_IMX_DEMOS_LIST) += imx_demos_list
APPS_GP-$(CONFIG_GP_IMX_EBIKE_VIT) += imx_ebike_vit
APPS_GP-$(CONFIG_GP_IMX_ELE) += imx_ele
APPS_GP-$(CONFIG_GP_IMX_NNSTREAMER_EXAMPLES) += imx_nnstreamer_examples
APPS_GP-$(CONFIG_GP_IMX_SMART_FITNESS) += imx_smart_fitness
APPS_GP-$(CONFIG_GP_IMX_SMART_KITCHEN) += imx_smart_kitchen
APPS_GP-$(CONFIG_GP_IMX_VIDEO2TEXTURE) += imx_video2texture
APPS_GP-$(CONFIG_GP_IMX_VOICEPLAYER) += imx_voiceplayer
APPS_GP-$(CONFIG_GP_IMX_VOICEUI) += imx_voiceui
APPS_GP-$(CONFIG_GP_NXP_AFE) += nxp_afe
APPS_GP-$(CONFIG_GP_IMX_CAMERA_ROTATION) += imx_camera_rotation
APPS_GP-$(CONFIG_GP_NXP_DEMO_EXPERIENCE_ASSETS) += nxp_demo_experience_assets

# Create alias for backward compatibility
APPS_GP := $(APPS_GP-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_GP-y), \
    $(eval include $(FBDIR)/src/apps/gopoint/$(m).mk))

# ============================================================================
# GoPoint target using APPS_GP-y
# ============================================================================
.PHONY: gopoint
gopoint: $(APPS_GP-y)
