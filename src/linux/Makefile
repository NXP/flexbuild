#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#
# SDK linux kernel and modules components

SHELL=/bin/bash
include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/utils.mk
include $(FBDIR)/include/download_repo.mk
include $(FBDIR)/include/patch_apply.mk
include $(FBDIR)/configs/.repo_pool


# Find and include all .mk files in this directory
LINUX_MK_FILES := $(wildcard $(FBDIR)/src/linux/*.mk)
include $(LINUX_MK_FILES)

# All Linux targets in this directory (derived from .mk files)
LINUX_TARGETS := $(basename $(notdir $(LINUX_MK_FILES)))
