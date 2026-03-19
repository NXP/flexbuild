#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#


# ============================================================================
# Define all possible ML/AI modules
# ============================================================================
ML_MODULES := \
    eiq_examples \
    ethosu_driver_stack \
    ethosu_firmware \
    ethosu_vela \
    flatbuffers \
    neutron \
    nnshark \
    nnstreamer_edge \
    nnstreamer \
    pytorch \
    ssat \
    tflite_ethosu_delegate \
    tflite \
    tflite_neutron_delegate \
    tflite_vx_delegate \
    tim_vx \
    tvm

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_ML-y :=

# Add modules based on CONFIG_ML_* settings
APPS_ML-$(CONFIG_ML_EIQ_EXAMPLES) += eiq_examples
APPS_ML-$(CONFIG_ML_ETHOSU_DRIVER_STACK) += ethosu_driver_stack
APPS_ML-$(CONFIG_ML_ETHOSU_FIRMWARE) += ethosu_firmware
APPS_ML-$(CONFIG_ML_ETHOSU_VELA) += ethosu_vela
APPS_ML-$(CONFIG_ML_FLATBUFFERS) += flatbuffers
APPS_ML-$(CONFIG_ML_NEUTRON) += neutron
APPS_ML-$(CONFIG_ML_NNSHARK) += nnshark
APPS_ML-$(CONFIG_ML_NNSTREAMER_EDGE) += nnstreamer_edge
APPS_ML-$(CONFIG_ML_NNSTREAMER) += nnstreamer
APPS_ML-$(CONFIG_ML_PYTORCH) += pytorch
APPS_ML-$(CONFIG_ML_SSAT) += ssat
APPS_ML-$(CONFIG_ML_TFLITE_ETHOSU_DELEGATE) += tflite_ethosu_delegate
APPS_ML-$(CONFIG_ML_TFLITE) += tflite
APPS_ML-$(CONFIG_ML_TFLITE_NEUTRON_DELEGATE) += tflite_neutron_delegate
APPS_ML-$(CONFIG_ML_TFLITE_VX_DELEGATE) += tflite_vx_delegate
APPS_ML-$(CONFIG_ML_TIM_VX) += tim_vx
APPS_ML-$(CONFIG_ML_TVM) += tvm

# Create alias for backward compatibility
APPS_ML := $(APPS_ML-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_ML-y), \
    $(eval include $(FBDIR)/src/apps/ml/$(m).mk))

# ============================================================================
# ML target using APPS_ML-y
# ============================================================================
.PHONY: ml
ml: $(APPS_ML-y)

