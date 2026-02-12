
#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#


# ============================================================================
# Define all possible robotics modules
# ============================================================================
ROBOTICS_MODULES := \
    ros

# ============================================================================
# Automatically include enabled modules and build APPS_ROBOTICS
# ============================================================================
APPS_ROBOTICS :=


$(foreach m,$(ROBOTICS_MODULES), \
    $(eval _m_upper = $(shell echo '$(m)' | tr 'a-z' 'A-Z')) \
    $(eval _cfg = CONFIG_ROBOTICS_$(_m_upper)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/robotics/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_ROBOTICS += $(m))) \
)

# ============================================================================
# Robotics target using APPS_ROBOTICS
# ============================================================================
.PHONY: robotics
robotics: $(APPS_ROBOTICS)

