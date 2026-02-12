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
    imx_dpu_g2d \
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
# Automatically include enabled modules and build APPS_GFX
# ============================================================================
APPS_GFX :=

$(foreach m,$(GFX_MODULES), \
    $(eval _cfg := CONFIG_GFX_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/graphics/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_GFX += $(m))) \
)

# ============================================================================
# Graphics target using APPS_GFX
# ============================================================================
.PHONY: graphics
graphics: $(APPS_GFX)

