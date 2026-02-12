#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#





# ============================================================================
# Define all possible multimedia modules
# ============================================================================
MM_MODULES := \
    alsa_lib \
    alsa_state \
    basler_camera \
    cheese \
    gstreamer \
    gst_plugins_base \
    gst_plugins_good \
    gst_plugins_bad \
    gst_plugins_ugly \
    gst_python \
    imx_alsa_plugin \
    imx_codec \
    imx_dspc_asrc \
    imx_dsp_codec_ext \
    imx_dsp \
    imx_gst_plugin \
    imx_isp \
    imx_lib \
    imx_parser \
    imx_sw_pdm \
    imx_vpu_hantro_daemon \
    imx_vpu_hantro \
    imx_vpu_hantro_vc \
    imx_vpuwrap \
    libcamera \
    neo_ipa_uguzzi \
    sof_zephyr

# ============================================================================
# Automatically include enabled modules and build APPS_MM
# ============================================================================
APPS_MM :=

$(foreach m,$(MM_MODULES), \
    $(eval _cfg := CONFIG_MM_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/multimedia/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_MM += $(m))) \
)

# ============================================================================
# Multimedia target using APPS_MM
# ============================================================================
.PHONY: multimedia
multimedia: $(APPS_MM)

