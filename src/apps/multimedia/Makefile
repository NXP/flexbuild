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
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_MM-y :=

# Add modules based on CONFIG_MM_* settings
APPS_MM-$(CONFIG_MM_ALSA_LIB) += alsa_lib
APPS_MM-$(CONFIG_MM_ALSA_STATE) += alsa_state
APPS_MM-$(CONFIG_MM_BASLER_CAMERA) += basler_camera
APPS_MM-$(CONFIG_MM_CHEESE) += cheese
APPS_MM-$(CONFIG_MM_GSTREAMER) += gstreamer
APPS_MM-$(CONFIG_MM_GST_PLUGINS_BASE) += gst_plugins_base
APPS_MM-$(CONFIG_MM_GST_PLUGINS_GOOD) += gst_plugins_good
APPS_MM-$(CONFIG_MM_GST_PLUGINS_BAD) += gst_plugins_bad
APPS_MM-$(CONFIG_MM_GST_PLUGINS_UGLY) += gst_plugins_ugly
APPS_MM-$(CONFIG_MM_GST_PYTHON) += gst_python
APPS_MM-$(CONFIG_MM_IMX_ALSA_PLUGIN) += imx_alsa_plugin
APPS_MM-$(CONFIG_MM_IMX_CODEC) += imx_codec
APPS_MM-$(CONFIG_MM_IMX_DSPC_ASRC) += imx_dspc_asrc
APPS_MM-$(CONFIG_MM_IMX_DSP_CODEC_EXT) += imx_dsp_codec_ext
APPS_MM-$(CONFIG_MM_IMX_DSP) += imx_dsp
APPS_MM-$(CONFIG_MM_IMX_GST_PLUGIN) += imx_gst_plugin
APPS_MM-$(CONFIG_MM_IMX_ISP) += imx_isp
APPS_MM-$(CONFIG_MM_IMX_LIB) += imx_lib
APPS_MM-$(CONFIG_MM_IMX_PARSER) += imx_parser
APPS_MM-$(CONFIG_MM_IMX_SW_PDM) += imx_sw_pdm
APPS_MM-$(CONFIG_MM_IMX_VPU_HANTRO_DAEMON) += imx_vpu_hantro_daemon
APPS_MM-$(CONFIG_MM_IMX_VPU_HANTRO) += imx_vpu_hantro
APPS_MM-$(CONFIG_MM_IMX_VPU_HANTRO_VC) += imx_vpu_hantro_vc
APPS_MM-$(CONFIG_MM_IMX_VPUWRAP) += imx_vpuwrap
APPS_MM-$(CONFIG_MM_LIBCAMERA) += libcamera
APPS_MM-$(CONFIG_MM_NEO_IPA_UGUZZI) += neo_ipa_uguzzi
APPS_MM-$(CONFIG_MM_SOF_ZEPHYR) += sof_zephyr

# Create alias for backward compatibility
APPS_MM := $(APPS_MM-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_MM-y), \
    $(eval include $(FBDIR)/src/apps/multimedia/$(m).mk))

# ============================================================================
# Multimedia target using APPS_MM-y
# ============================================================================
.PHONY: multimedia
multimedia: $(APPS_MM-y)
