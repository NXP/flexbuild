#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components

SHELL=/bin/bash
.SHELLFLAGS := $(SHFLAGS)

include $(FBDIR)/configs/$(CONFIGLIST)
include $(FBDIR)/include/utils.mk
include $(FBDIR)/include/download_repo.mk
include $(FBDIR)/include/patch_apply.mk

BSP_MK_FILES := $(wildcard $(FBDIR)/src/bsp/*.mk)
include $(BSP_MK_FILES)

BSP_TARGETS := $(basename $(notdir $(BSP_MK_FILES)))

BSPDIR = $(PKGDIR)/bsp
