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
# Automatically include enabled modules and build APPS_ML
# ============================================================================
APPS_ML :=
$(foreach m,$(ML_MODULES), \
    $(eval _cfg := CONFIG_ML_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/ml/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_ML += $(m))) \
)

# ============================================================================
# ML target using APPS_ML
# ============================================================================
.PHONY: ml
ml: $(APPS_ML)


