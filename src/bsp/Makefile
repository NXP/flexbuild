#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components


#EXCLUDE_BSPMK_FILES := grub.mk
#BSP_MK_FILES := $(filter-out $(addprefix $(FBDIR)/src/bsp/,$(EXCLUDE_BSPMK_FILES)),$(wildcard $(FBDIR)/src/bsp/*.mk))


BSP_MK_FILES := $(wildcard $(FBDIR)/src/bsp/*.mk)
include $(BSP_MK_FILES)

BSP_TARGETS := $(basename $(notdir $(BSP_MK_FILES)))

BSPDIR = $(PKGDIR)/bsp
