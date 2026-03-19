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
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_ROBOTICS-y :=

# Add modules based on CONFIG_ROBOTICS_* settings
APPS_ROBOTICS-$(CONFIG_ROBOTICS_ROS) += ros

# Create alias for backward compatibility
APPS_ROBOTICS := $(APPS_ROBOTICS-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_ROBOTICS-y), \
    $(eval include $(FBDIR)/src/apps/robotics/$(m).mk))

# ============================================================================
# Robotics target using APPS_ROBOTICS-y
# ============================================================================
.PHONY: robotics
robotics: $(APPS_ROBOTICS-y)
