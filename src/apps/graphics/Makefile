#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#


# ============================================================================
# Define all possible graphics modules
# ============================================================================
GFX_MODULES := \
    apitrace \
    clutter_gst \
    cogl \
    gputop \
    gpu_viv \
    imx_dpu_g2d_v1 \
    imx_dpu_g2d_v2 \
    imx_g2d_samples \
    imx_gpu_g2d \
    imx_pxp_g2d \
    libdrm \
    libgpuperfcnt \
    mali_imx \
    vkmark \
    vulkan_headers \
    wayland \
    wayland_protocols \
    weston

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_GFX-y :=

# Add modules based on CONFIG_GFX_* settings
APPS_GFX-$(CONFIG_GFX_APITRACE) += apitrace
APPS_GFX-$(CONFIG_GFX_CLUTTER_GST) += clutter_gst
APPS_GFX-$(CONFIG_GFX_COGL) += cogl
APPS_GFX-$(CONFIG_GFX_GPUTOP) += gputop
APPS_GFX-$(CONFIG_GFX_GPU_VIV) += gpu_viv
APPS_GFX-$(CONFIG_GFX_IMX_DPU_G2D_V1) += imx_dpu_g2d_v1
APPS_GFX-$(CONFIG_GFX_IMX_DPU_G2D_V2) += imx_dpu_g2d_v2
APPS_GFX-$(CONFIG_GFX_IMX_G2D_SAMPLES) += imx_g2d_samples
APPS_GFX-$(CONFIG_GFX_IMX_GPU_G2D) += imx_gpu_g2d
APPS_GFX-$(CONFIG_GFX_IMX_PXP_G2D) += imx_pxp_g2d
APPS_GFX-$(CONFIG_GFX_LIBDRM) += libdrm
APPS_GFX-$(CONFIG_GFX_LIBGPUPERFCNT) += libgpuperfcnt
APPS_GFX-$(CONFIG_GFX_MALI_IMX) += mali_imx
APPS_GFX-$(CONFIG_GFX_VKMARK) += vkmark
APPS_GFX-$(CONFIG_GFX_VULKAN_HEADERS) += vulkan_headers
APPS_GFX-$(CONFIG_GFX_WAYLAND) += wayland
APPS_GFX-$(CONFIG_GFX_WAYLAND_PROTOCOLS) += wayland_protocols
APPS_GFX-$(CONFIG_GFX_WESTON) += weston

# Create alias for backward compatibility
APPS_GFX := $(APPS_GFX-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_GFX-y), \
    $(eval include $(FBDIR)/src/apps/graphics/$(m).mk))

# ============================================================================
# Graphics target using APPS_GFX-y
# ============================================================================
.PHONY: graphics
graphics: $(APPS_GFX-y)
